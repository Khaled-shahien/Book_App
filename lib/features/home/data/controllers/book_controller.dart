import 'package:book_app/core/models/book_model.dart';
import 'package:book_app/core/api/book_services.dart';
import 'package:get/get.dart';
import 'dart:developer';

class BookController extends GetxController {
  final BookServices bookServices = BookServices();

  var books = <BookModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var currentQuery = 'Flutter'.obs;
  var selectedCategoryIndex = 0.obs;
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
      log('⚡ Cache hit for: $query');
      books.value = _cache[query]!;
      isLoading.value = false;
      return;
    }

    try {
      log('🔄 Searching for: $query');

      final results = await bookServices.fetchBooks(query);

      if (results.isEmpty) {
        log('📭 No books found for query: $query');
        books.clear();
        errorMessage.value = 'No books found for "$query"';
      } else {
        final bookList = results
            .map((json) => BookModel.fromJson(json))
            .toList();
        books.value = bookList;
        _cache[query] = bookList;
        log('✅ Successfully loaded ${books.length} books');
      }
    } catch (e) {
      log('❌ Error in searchBooks: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      books.clear();

      // عرض snackbar للخطأ
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

  // Method لتحديث البحث
  void refreshSearch() {
    searchBooks(currentQuery.value);
  }

  // Method للبحث حسب الفئة
  void searchByCategory(String category) {
    searchBooks('subject:$category');
  }

  // Method للبحث حسب المؤلف
  void searchByAuthor(String author) {
    searchBooks('inauthor:$author');
  }
}
