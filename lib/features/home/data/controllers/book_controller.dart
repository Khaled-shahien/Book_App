import 'dart:async';
import 'dart:collection';

import 'package:book_app/core/api/book_services.dart';
import 'package:book_app/core/error/failure.dart';
import 'package:book_app/core/models/book_model.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// Holds the result of a book search.
///
/// One instance per screen: the Home tab uses an untagged instance, each
/// category screen uses its own tagged instance, so they never overwrite
/// each other's results.
class BookController extends GetxController {
  BookController({
    BookServices? bookServices,
    this.initialQuery = 'Flutter',
    this.maxCacheEntries = 20,
  }) : bookServices = bookServices ?? BookServices();

  final BookServices bookServices;
  final String initialQuery;
  final int maxCacheEntries;

  final books = <BookModel>[].obs;
  final isLoading = false.obs;

  /// User-presentable error for the last failed search; empty if none.
  final errorMessage = ''.obs;
  final currentQuery = ''.obs;
  final selectedCategoryIndex = 0.obs;

  // Insertion-ordered map used as a small LRU cache.
  final LinkedHashMap<String, List<BookModel>> _cache = LinkedHashMap();
  CancelToken? _inFlight;
  int _requestId = 0;

  bool get hasError => errorMessage.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    unawaited(searchBooks(initialQuery));
  }

  @override
  void onClose() {
    _inFlight?.cancel('controller closed');
    super.onClose();
  }

  Future<void> searchBooks(String rawQuery, {bool forceRefresh = false}) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      errorMessage.value = 'Please enter a search term';
      return;
    }

    // Supersede any in-flight request so a slow, older response can never
    // overwrite a newer one.
    final requestId = ++_requestId;
    _inFlight?.cancel('superseded');
    final token = _inFlight = CancelToken();

    currentQuery.value = query;
    errorMessage.value = '';

    final cached = forceRefresh ? null : _cache.remove(query);
    if (cached != null) {
      _cache[query] = cached; // mark as most recently used
      books.assignAll(cached);
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    try {
      final result = await bookServices.fetchBooks(query, cancelToken: token);
      if (requestId != _requestId || isClosed) return;
      books.assignAll(result);
      if (result.isEmpty) {
        errorMessage.value = '';
      } else {
        _putCache(query, result);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;
      if (requestId != _requestId || isClosed) return;
      books.clear();
      errorMessage.value = BookServices.mapDioException(e).message;
    } on Failure catch (f) {
      if (requestId != _requestId || isClosed) return;
      books.clear();
      errorMessage.value = f.message;
    } catch (_) {
      if (requestId != _requestId || isClosed) return;
      books.clear();
      errorMessage.value = const UnknownFailure().message;
    } finally {
      if (requestId == _requestId && !isClosed) isLoading.value = false;
    }
  }

  Future<void> refreshSearch() {
    final query = currentQuery.value.isEmpty
        ? initialQuery
        : currentQuery.value;
    return searchBooks(query, forceRefresh: true);
  }

  void _putCache(String query, List<BookModel> result) {
    _cache[query] = result;
    while (_cache.length > maxCacheEntries) {
      _cache.remove(_cache.keys.first);
    }
  }
}
