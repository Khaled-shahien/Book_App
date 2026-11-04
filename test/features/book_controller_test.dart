import 'dart:async';

import 'package:book_app/core/api/book_services.dart';
import 'package:book_app/core/error/failure.dart';
import 'package:book_app/core/models/book_model.dart';
import 'package:book_app/features/home/data/controllers/book_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

class FakeBookServices extends BookServices {
  FakeBookServices() : super(dio: Dio());

  final Map<String, Completer<List<BookModel>>> pending = {};
  final List<String> queries = [];

  @override
  Future<List<BookModel>> fetchBooks(
    String query, {
    int maxResults = 30,
    CancelToken? cancelToken,
  }) {
    queries.add(query);
    return (pending[query] = Completer<List<BookModel>>()).future;
  }

  void complete(String q, List<BookModel> books) => pending[q]!.complete(books);

  void fail(String q, Object error) => pending[q]!.completeError(error);
}

void main() {
  late FakeBookServices fake;
  late BookController controller;

  setUp(() {
    fake = FakeBookServices();
    controller = BookController(bookServices: fake, initialQuery: 'init')
      ..onInit();
  });

  test('loads the initial query on init', () async {
    expect(controller.isLoading.value, isTrue);
    fake.complete('init', [book()]);
    await pumpEventQueue();
    expect(controller.books, hasLength(1));
    expect(controller.isLoading.value, isFalse);
    expect(controller.hasError, isFalse);
  });

  test('a stale response never overwrites a newer one', () async {
    final second = controller.searchBooks('newer');
    fake.complete('newer', [book(id: 'new')]);
    await second;
    fake.complete('init', [book(id: 'old')]); // arrives late
    await pumpEventQueue();
    expect(controller.books.single.id, 'new');
    expect(controller.currentQuery.value, 'newer');
    expect(controller.isLoading.value, isFalse);
  });

  test('typed failures surface their message and clear results', () async {
    fake.fail('init', const NetworkFailure());
    await pumpEventQueue();
    expect(controller.errorMessage.value, const NetworkFailure().message);
    expect(controller.books, isEmpty);
    expect(controller.isLoading.value, isFalse);
  });

  test('unknown errors never leak raw exception text', () async {
    fake.fail('init', StateError('secret internals'));
    await pumpEventQueue();
    expect(controller.hasError, isTrue);
    expect(controller.errorMessage.value, isNot(contains('secret')));
  });

  test('serves repeated queries from cache; refresh bypasses it', () async {
    fake.complete('init', [book()]);
    await pumpEventQueue();
    await controller.searchBooks('init');
    expect(fake.queries, ['init']);

    final refresh = controller.refreshSearch();
    fake.complete('init', [book(id: 'fresh')]);
    await refresh;
    expect(fake.queries, ['init', 'init']);
    expect(controller.books.single.id, 'fresh');
  });

  test('blank queries are rejected without a request', () async {
    fake.complete('init', const []);
    await pumpEventQueue();
    await controller.searchBooks('   ');
    expect(fake.queries, ['init']);
    expect(controller.hasError, isTrue);
  });

  test('cache is bounded (LRU eviction)', () async {
    final c = BookController(
      bookServices: fake,
      initialQuery: 'q0',
      maxCacheEntries: 2,
    )..onInit();
    fake.complete('q0', [book()]);
    await pumpEventQueue();
    for (final q in ['q1', 'q2']) {
      final f = c.searchBooks(q);
      fake.complete(q, [book()]);
      await f;
    }
    // q0 was evicted, so searching it again hits the network.
    final again = c.searchBooks('q0');
    expect(fake.queries.where((q) => q == 'q0'), hasLength(2));
    fake.complete('q0', [book()]);
    await again;
  });
}
