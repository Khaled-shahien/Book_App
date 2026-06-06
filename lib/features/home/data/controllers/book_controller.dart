import 'dart:developer';

import 'package:book_app/core/api/book_services.dart';
import 'package:book_app/core/models/book_model.dart';
import 'package:get/get.dart';

class BookController extends GetxController {
  final BookServices bookServices = BookServices();

  final books = <BookModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final currentQuery = 'Flutter'.obs;
  final selectedCategoryIndex = 0.obs;
  final Map<String, List<BookModel>> _cache = {};

  @override
  void onInit() {
    super.onInit();
    searchBooks('Flutter');
  }

  Future<void> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      errorMessage.value = 'Please enter a search term';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    currentQuery.value = query;

    if (_cache.containsKey(query)) {
      log('Cache hit for: $query');
      books.value = _cache[query]!;
      isLoading.value = false;
      return;
    }

    try {
      log('Searching for: $query');

      final results = await bookServices.fetchBooks(query);
      final bookList = results
          .whereType<Map<String, dynamic>>()
          .map(BookModel.fromJson)
          .toList();

      if (bookList.isEmpty) {
        log('No books found for query: $query');
        books.clear();
        errorMessage.value = 'No books found for "$query"';
      } else {
        books.value = bookList;
        _cache[query] = bookList;
        log('Successfully loaded ${books.length} books');
      }
    } catch (e) {
      log('Error in searchBooks: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      books.clear();

      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void refreshSearch() {
    searchBooks(currentQuery.value);
  }

  void searchByCategory(String category) {
    searchBooks('subject:$category');
  }

  void searchByAuthor(String author) {
    searchBooks('inauthor:$author');
  }
}
