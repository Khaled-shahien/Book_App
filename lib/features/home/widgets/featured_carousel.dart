// widgets/featured_carousel.dart
import 'package:book_app/features/details/book_details_page.dart';
import 'package:flutter/material.dart';
import 'package:book_app/core/models/book_model.dart';
import 'package:get/get.dart';

class FeaturedCarousel extends StatefulWidget {
  final List<BookModel> books;
  const FeaturedCarousel({super.key, required this.books});

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  final _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (_currentPage != page) setState(() => _currentPage = page);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '🔥 Trending Now',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.books.length,
            itemBuilder: (context, index) => _FeaturedCard(
              book: widget.books[index],
              isActive: index == _currentPage,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildIndicators(),
      ],
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.books.length > 5 ? 5 : widget.books.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: i == _currentPage
                ? const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF8B7FFF)],
                  )
                : null,
            color: i == _currentPage ? null : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final BookModel book;
  final bool isActive;

  const _FeaturedCard({required this.book, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: isActive ? 0 : 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withValues(alpha: 0.9),
            const Color(0xFF8B7FFF).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF6C63FF,
            ).withValues(alpha: isActive ? 0.4 : 0.2),
            blurRadius: isActive ? 20 : 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            _buildBackground(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(flex: 3, child: _buildContent(context)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _buildThumbnail()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      right: -20,
      top: -20,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            book.category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          book.authors,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 13,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Get.to(() => BookDetailsPage(book: book));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'View Details',
              style: TextStyle(
                color: Color(0xFF6C63FF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: book.thumbnail.isNotEmpty
          ? Image.network(
              book.thumbnail,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    height: 160,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(Icons.book, size: 40, color: Colors.white),
  );
}
