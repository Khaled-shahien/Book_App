import 'dart:convert';
import 'dart:typed_data';

import 'package:book_app/core/api/book_services.dart';
import 'package:book_app/core/error/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

/// Scripted HTTP adapter: each call pops the next response or error type.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.script);

  final List<Object> script; // ResponseBody or DioExceptionType
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final next = script[calls++];
    if (next is DioExceptionType) {
      throw DioException(requestOptions: options, type: next);
    }
    return next as ResponseBody;
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, {int status = 200}) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

BookServices _service(_ScriptedAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/'))
    ..httpClientAdapter = adapter;
  return BookServices(dio: dio, retryBaseDelay: Duration.zero);
}

void main() {
  test('parses items and drops entries without an id', () async {
    final adapter = _ScriptedAdapter([
      _json({
        'items': [volumeJson(), volumeJson(id: ''), 'garbage'],
      }),
    ]);
    final books = await _service(adapter).fetchBooks('q');
    expect(books, hasLength(1));
    expect(books.single.id, 'id-1');
  });

  test('missing items yields an empty list', () async {
    final adapter = _ScriptedAdapter([
      _json({'totalItems': 0}),
    ]);
    expect(await _service(adapter).fetchBooks('q'), isEmpty);
  });

  test('retries transient errors, then succeeds', () async {
    final adapter = _ScriptedAdapter([
      DioExceptionType.connectionError,
      DioExceptionType.receiveTimeout,
      _json({
        'items': [volumeJson()],
      }),
    ]);
    final books = await _service(adapter).fetchBooks('q');
    expect(books, hasLength(1));
    expect(adapter.calls, 3);
  });

  test('gives up after max retries with a typed failure', () async {
    final adapter = _ScriptedAdapter(
      List<Object>.filled(3, DioExceptionType.connectionError),
    );
    await expectLater(
      _service(adapter).fetchBooks('q'),
      throwsA(isA<NetworkFailure>()),
    );
    expect(adapter.calls, 3);
  });

  test('does not retry 429; maps it to RateLimitFailure', () async {
    final adapter = _ScriptedAdapter([
      _json({'error': 'slow down'}, status: 429),
    ]);
    await expectLater(
      _service(adapter).fetchBooks('q'),
      throwsA(isA<RateLimitFailure>()),
    );
    expect(adapter.calls, 1);
  });

  test('maps timeouts', () {
    final e = DioException(
      requestOptions: RequestOptions(),
      type: DioExceptionType.connectionTimeout,
    );
    expect(BookServices.mapDioException(e), isA<TimeoutFailure>());
  });
}
