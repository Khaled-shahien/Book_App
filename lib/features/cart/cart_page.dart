// screens/cart_page.dart
import 'package:book_app/core/controllers/nav_controller.dart';
import 'package:flutter/material.dart';
import 'package:book_app/core/models/book_model.dart';
import 'package:get/get.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // Listen to cart changes
    CartManager.addListener(_onCartChanged);
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {
        // Rebuild when cart changes
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    CartManager.removeListener(_onCartChanged);
    super.dispose();
  }

  void _removeFromCart(BookModel book) {
    CartManager.removeFromCart(book);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${book.title} removed from cart'),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Cart?'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              CartManager.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cart cleared'),
                  backgroundColor: Colors.green.shade400,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = CartManager.cartItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          if (cartItems.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildCartItems(cartItems),
                    const SizedBox(height: 20),
                    _buildSummary(cartItems),
                    const SizedBox(height: 20),
                    _buildCheckoutButton(),
                    const SizedBox(height: 100), // Extra space for bottom nav
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final itemCount = CartManager.cartItems.length;

    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: const Color(0xFF6C63FF),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {
          Get.find<NavController>().changeIndex(0);
        },
      ),
      actions: [
        if (itemCount > 0)
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: _clearCart,
            tooltip: 'Clear Cart',
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(60, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'My Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: const Color(0xFF6C63FF).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add some books to get started!',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Get.find<NavController>().changeIndex(1);
            },
            icon: const Icon(Icons.explore),
            label: const Text('Browse Books'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(List<BookModel> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _CartItemCard(
          book: items[index],
          onRemove: () => _removeFromCart(items[index]),
        );
      },
    );
  }

  Widget _buildSummary(List<BookModel> items) {
    final total = items.fold<double>(
      0.0,
      (sum, book) => sum + (book.isFree ? 0.0 : 9.99),
    );
    final freeCount = items.where((book) => book.isFree).length;
    final paidCount = items.length - freeCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6C63FF).withValues(alpha: 0.1),
              const Color(0xFF8B7FFF).withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _buildSummaryRow(
              'Free Books',
              '$freeCount',
              Icons.workspace_premium,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Paid Books', '$paidCount', Icons.payments),
            const SizedBox(height: 12),
            Divider(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                Text(
                  total == 0 ? 'Free' : '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6C63FF)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3142),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Checkout feature coming soon!'),
              backgroundColor: Colors.green.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF6C63FF).withValues(alpha: 0.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 24),
            SizedBox(width: 12),
            Text(
              'Proceed to Checkout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onRemove;

  const _CartItemCard({required this.book, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Dismissible(
          key: Key(book.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onRemove(),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade300, Colors.red.shade500],
              ),
            ),
            child: const Icon(Icons.delete, color: Colors.white, size: 32),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildThumbnail(),
                const SizedBox(width: 16),
                Expanded(child: _buildInfo()),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 80,
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: book.thumbnail.isNotEmpty
            ? Image.network(
                book.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _placeholderThumbnail(),
              )
            : _placeholderThumbnail(),
      ),
    );
  }

  Widget _placeholderThumbnail() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withValues(alpha: 0.3),
            const Color(0xFF8B7FFF).withValues(alpha: 0.3),
          ],
        ),
      ),
      child: const Icon(Icons.book, size: 40, color: Colors.white),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                book.authors,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: book.isFree ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: book.isFree
                  ? Colors.green.shade200
                  : Colors.orange.shade200,
            ),
          ),
          child: Text(
            book.isFree ? 'Free' : '\$9.99',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: book.isFree
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return IconButton(
      onPressed: onRemove,
      icon: const Icon(Icons.delete_outline),
      color: Colors.red.shade400,
      iconSize: 26,
      tooltip: 'Remove',
    );
  }
}

// CartManager with ChangeNotifier pattern
class CartManager {
  static final List<BookModel> _cartItems = [];
  static final List<VoidCallback> _listeners = [];

  static List<BookModel> get cartItems => List.unmodifiable(_cartItems);

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  static void addToCart(BookModel book) {
    if (!_cartItems.any((item) => item.id == book.id)) {
      _cartItems.add(book);
      _notifyListeners();
    }
  }

  static void removeFromCart(BookModel book) {
    _cartItems.removeWhere((item) => item.id == book.id);
    _notifyListeners();
  }

  static void clearCart() {
    _cartItems.clear();
    _notifyListeners();
  }

  static bool isInCart(BookModel book) {
    return _cartItems.any((item) => item.id == book.id);
  }
}
