import 'dart:async';

// home_view.dart

import 'package:book_app/core/models/book_model.dart';
import 'package:book_app/core/widgets/error_state_view.dart';
import 'package:book_app/features/home/data/controllers/book_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widgets/books_section.dart';
import 'widgets/category_chips.dart';
import 'widgets/featured_carousel.dart';
import 'widgets/home_app_bar.dart';

/// Home tab. The [BookController] is registered by the home route binding.
class HomeView extends GetView<BookController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshSearch,
          child: Obx(() {
            final books = controller.books;
            final loading = controller.isLoading.value;
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                HomeAppBar(onSearch: _showSearchDialog),
                // Keep the category chips visible in every state so the user
                // can always switch category, even after an error.
                if (!(loading && books.isEmpty))
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: CategoryChips(controller: controller),
                    ),
                  ),
                if (loading && books.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  ),
                if (loading && books.isEmpty)
                  _buildLoading()
                else if (controller.hasError && books.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorStateView(
                      message: controller.errorMessage.value,
                      onRetry: controller.refreshSearch,
                    ),
                  )
                else if (books.isEmpty)
                  _buildEmpty()
                else
                  _buildContent(books),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildContent(List<BookModel> books) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 24),
          FeaturedCarousel(books: books.take(5).toList()),
          const SizedBox(height: 24),
          BooksSection(
            title: '📚 Popular Books',
            books: books,
            type: BooksSectionType.horizontal,
          ),
          const SizedBox(height: 24),
          BooksSection(
            title: '✨ New Releases',
            books: books,
            type: BooksSectionType.grid,
            maxItems: 10,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(Color(0xFF6C63FF)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading amazing books...',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 80,
                color: const Color(0xFF6C63FF).withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No books found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for something else',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        void submit() {
          final query = searchController.text.trim();
          if (query.isEmpty) return;
          controller.selectedCategoryIndex.value = -1;
          unawaited(controller.searchBooks(query));
          Navigator.pop(dialogContext);
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogHeader(),
                const SizedBox(height: 20),
                _buildSearchField(searchController, submit),
                const SizedBox(height: 20),
                _buildDialogActions(dialogContext, submit),
              ],
            ),
          ),
        );
      },
    ).whenComplete(searchController.dispose);
  }

  Widget _buildDialogHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF8B7FFF)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.search, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        const Text(
          'Search Books',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSearchField(
    TextEditingController controller,
    VoidCallback onSubmit,
  ) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmit(),
      maxLength: 100,
      decoration: InputDecoration(
        hintText: 'Enter book name or author...',
        counterText: '',
        prefixIcon: const Icon(Icons.edit_rounded),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      autofocus: true,
    );
  }

  Widget _buildDialogActions(BuildContext context, VoidCallback onSubmit) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Search', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
