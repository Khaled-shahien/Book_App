// widgets/category_books_view.dart
import 'package:book_app/features/details/book_details_page.dart';
import 'package:flutter/material.dart';
import 'package:book_app/features/home/data/controllers/book_controller.dart';
import 'package:book_app/core/models/book_model.dart';
import 'package:get/get.dart';

class CategoryBooksPage extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;
  final Color categoryColor;

  const CategoryBooksPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
  });

  @override
  State<CategoryBooksPage> createState() => _CategoryBooksPageState();
}

class _CategoryBooksPageState extends State<CategoryBooksPage> {
  final BookController controller = Get.find<BookController>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => controller.searchBooks(widget.categoryName));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(screenWidth),
          Obx(() => _buildContent(screenWidth, crossAxisCount)),
        ],
      ),
    );
  }

  Widget _buildAppBar(double screenWidth) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: widget.categoryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _buildAppBarBackground(),
        title: _buildAppBarTitle(screenWidth),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16, right: 20),
      ),
    );
  }

  Widget _buildAppBarBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.categoryColor,
            widget.categoryColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle(double screenWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.categoryIcon,
                style: TextStyle(fontSize: screenWidth > 400 ? 28 : 24),
              ),
              const SizedBox(width: 12),
              Text(
                widget.categoryName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth > 400 ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(double screenWidth, int crossAxisCount) {
    if (controller.isLoading.value) return _buildLoading();
    if (controller.books.isEmpty) return _buildEmpty();
    return _buildBooksGrid(screenWidth, crossAxisCount);
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
              'Loading books...',
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
                color: widget.categoryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 80,
                color: widget.categoryColor.withValues(alpha: 0.5),
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
              'Try another category',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksGrid(double screenWidth, int crossAxisCount) {
    return SliverPadding(
      padding: EdgeInsets.all(screenWidth > 600 ? 24 : 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: screenWidth > 600 ? 0.7 : 0.65,
          crossAxisSpacing: screenWidth > 600 ? 16 : 12,
          mainAxisSpacing: screenWidth > 600 ? 16 : 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => BookGridCard(
            book: controller.books[index],
            color: widget.categoryColor,
          ),
          childCount: controller.books.length,
        ),
      ),
    );
  }
}

class BookGridCard extends StatelessWidget {
  final BookModel book;
  final Color color;

  const BookGridCard({super.key, required this.book, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 140;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildCover(constraints, isSmall)),
              Flexible(flex: 1, child: _buildInfo(isSmall)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCover(BoxConstraints constraints, bool isSmall) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            Get.to(BookDetailsPage(book: book));
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: book.thumbnail.isNotEmpty
                ? Image.network(
                    book.thumbnail,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => _placeholder(),
                  )
                : _placeholder(),
          ),
        ),
        _buildCategoryBadge(constraints, isSmall),
        _buildFavoriteButton(isSmall),
      ],
    );
  }

  Widget _buildCategoryBadge(BoxConstraints constraints, bool isSmall) {
    return Positioned(
      top: 6,
      left: 6,
      child: Container(
        constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.6),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 6 : 8,
          vertical: isSmall ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          book.category,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmall ? 8 : 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(bool isSmall) {
    return Positioned(
      top: 6,
      right: 6,
      child: Container(
        padding: EdgeInsets.all(isSmall ? 4 : 6),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.favorite_border,
          size: isSmall ? 14 : 16,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfo(bool isSmall) {
    return Padding(
      padding: EdgeInsets.all(isSmall ? 8 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isSmall ? 11 : 12,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            book.authors,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isSmall ? 9 : 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    color: Colors.grey[100],
    child: Center(child: Icon(Icons.book, size: 40, color: Colors.grey[400])),
  );
}
