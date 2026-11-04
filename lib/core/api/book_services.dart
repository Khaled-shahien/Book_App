import 'dart:async';

import 'package:book_app/core/config/app_config.dart';
import 'package:book_app/core/error/failure.dart';
import 'package:book_app/core/models/book_model.dart';
import 'package:book_app/core/utils/app_logger.dart';
import 'package:dio/dio.dart';

/// Remote data source for the Google Books API.
///
/// * HTTPS base URL from [AppConfig] (no hardcoded keys).
/// * Timeouts on connect/send/receive.
/// * Retries idempotent GETs with exponential backoff on transient errors.
/// * Maps every error to a typed [Failure]; never leaks raw exceptions.
class BookServices {
  BookServices({
    Dio? dio,
    this.maxRetries = 2,
    this.retryBaseDelay = const Duration(milliseconds: 400),
  }) : _dio = dio ?? _createDio();

  final Dio _dio;
  final int maxRetries;
  final Duration retryBaseDelay;

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.booksApiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
      ),
    );
  }

  /// Fetches up to [maxResults] books for [query].
  ///
  /// Throws a [Failure] on error. Pass a [cancelToken] to abort the request
  /// when the caller is disposed.
  Future<List<BookModel>> fetchBooks(
    String query, {
    int maxResults = 30,
    CancelToken? cancelToken,
  }) async {
    final params = <String, Object>{
      'q': query,
      'maxResults': maxResults.clamp(1, 40),
      'orderBy': 'relevance',
      'printType': 'books',
      if (AppConfig.booksApiKey.isNotEmpty) 'key': AppConfig.booksApiKey,
    };

    var attempt = 0;
    while (true) {
      try {
        AppLogger.debug('GET volumes q="$query" (attempt ${attempt + 1})');
        final response = await _dio.get<Object?>(
          'volumes',
          queryParameters: params,
          cancelToken: cancelToken,
        );
        return parseVolumes(response.data);
      } on DioException catch (e, st) {
        if (e.type == DioExceptionType.cancel) rethrow;
        final failure = mapDioException(e);
        final transient =
            failure is NetworkFailure ||
            failure is TimeoutFailure ||
            (failure is ServerFailure && (e.response?.statusCode ?? 0) >= 500);
        if (transient && attempt < maxRetries) {
          attempt++;
          await Future<void>.delayed(retryBaseDelay * (1 << (attempt - 1)));
          continue;
        }
        AppLogger.reportError(e, st, reason: 'fetchBooks failed');
        throw failure;
      } on Failure {
        rethrow;
      } catch (e, st) {
        AppLogger.reportError(e, st, reason: 'fetchBooks unexpected');
        throw const UnknownFailure();
      }
    }
  }

  /// Parses a `volumes` response body defensively; unexpected shapes yield
  /// an empty list instead of a crash.
  static List<BookModel> parseVolumes(Object? body) {
    if (body is! Map<String, dynamic>) {
      if (body == null) return const [];
      throw const ServerFailure('Unexpected response from the server.');
    }
    final items = body['items'];
    if (items is! List) return const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(BookModel.fromJson)
        .where((book) => book.id.isNotEmpty)
        .toList(growable: false);
  }

  static Failure mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        if (code == 429) return const RateLimitFailure();
        return const ServerFailure();
      case DioExceptionType.badCertificate:
        return const NetworkFailure('Secure connection failed.');
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return const UnknownFailure();
    }
  }
}
