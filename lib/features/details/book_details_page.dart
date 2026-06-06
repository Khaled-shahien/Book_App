// screens/book_details_page.dart
import 'package:book_app/core/controllers/nav_controller.dart';
import 'package:book_app/features/cart/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:book_app/core/models/book_model.dart';
import 'package:get/get.dart';

class BookDetailsPage extends StatefulWidget {
  final BookModel book;

  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  bool _isInCart = false;

  @override
  void initState() {
    super.initState();
    _checkIfInCart();
  }

  void _checkIfInCart() {
    setState(() {
      _isInCart = CartManager.isInCart(widget.book);
    });
  }

  void _addToCart() {
    CartManager.addToCart(widget.book);
    setState(() {
      _isInCart = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('${widget.book.title} added to cart')),
          ],
        ),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pop(context);
            Get.find<NavController>().changeIndex(2);
          },
        ),
      ),
    );
  }

  void _removeFromCart() {
    CartManager.removeFromCart(widget.book);
    setState(() {
      _isInCart = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.remove_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('${widget.book.title} removed from cart')),
          ],
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            _addToCart();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildBookInfo(),
                const SizedBox(height: 24),
                _buildStats(),
                const SizedBox(height: 16),
                _buildRatingInfo(),
                const SizedBox(height: 24),
                _buildDescription(),
                const SizedBox(height: 24),
                _buildActionButtons(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: const Color(0xFF6C63FF),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            _isInCart ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
          ),
          onPressed: () {
            if (_isInCart) {
              _removeFromCart();
            } else {
              _addToCart();
            }
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C63FF),
                    const Color(0xFF8B7FFF).withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
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
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Hero(
                  tag: 'book_${widget.book.title}',
                  child: _buildCover(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    return Container(
      width: 180,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: widget.book.thumbnail.isNotEmpty
            ? Image.network(
                widget.book.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _placeholderCover(),
              )
            : _placeholderCover(),
      ),
    );
  }

  Widget _placeholderCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withValues(alpha: 0.3),
            const Color(0xFF8B7FFF).withValues(alpha: 0.3),
          ],
        ),
      ),
      child: const Icon(Icons.book, size: 80, color: Colors.white),
    );
  }

  Widget _buildBookInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF8B7FFF)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.book.category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.book.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 18,
                color: Color(0xFF6C63FF),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.book.authors,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildStatCard(
            Icons.calendar_today,
            _formatDate(widget.book.publishedDate),
            'Published',
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            widget.book.isFree ? Icons.workspace_premium : Icons.payments,
            widget.book.isFree ? 'Free' : 'Paid',
            'Access',
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            Icons.menu_book,
            widget.book.pageCount > 0
                ? widget.book.pageCount.toString()
                : 'N/A',
            'Pages',
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    if (date == 'Unknown' || date.isEmpty) return 'N/A';
    if (date.length == 4) return date;
    try {
      final parts = date.split('-');
      if (parts.isNotEmpty) return parts[0];
      return date;
    } catch (e) {
      return date;
    }
  }

  Widget _buildRatingInfo() {
    if (widget.book.rating <= 0 && widget.book.ratingsCount <= 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (widget.book.rating > 0) ...[
              const Icon(Icons.star, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(
                widget.book.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/ 5',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],

            if (widget.book.rating > 0 && widget.book.ratingsCount > 0)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: 1,
                height: 30,
                color: Colors.grey[300],
              ),

            if (widget.book.ratingsCount > 0) ...[
              const Icon(Icons.rate_review, color: Color(0xFF6C63FF), size: 22),
              const SizedBox(width: 8),
              Text(
                '${widget.book.ratingsCount} Reviews',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    Color iconColor = const Color(0xFF6C63FF);
    Color valueColor = const Color(0xFF2D3142);

    if (label == 'Access') {
      if (value == 'Free') {
        iconColor = Colors.green;
        valueColor = Colors.green.shade700;
      } else if (value == 'Paid') {
        iconColor = Colors.orange;
        valueColor = Colors.orange.shade700;
      }
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.book.description.isNotEmpty
                  ? widget.book.description
                  : 'No description available for this book. Discover the story by exploring its pages!',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (_isInCart) {
                  _removeFromCart();
                } else {
                  _addToCart();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isInCart
                    ? Colors.red.shade400
                    : const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
                shadowColor:
                    (_isInCart ? Colors.red.shade400 : const Color(0xFF6C63FF))
                        .withValues(alpha: 0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isInCart
                        ? Icons.remove_shopping_cart
                        : Icons.add_shopping_cart,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isInCart ? 'Remove from Cart' : 'Add to Cart',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preview coming soon!')),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Preview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
