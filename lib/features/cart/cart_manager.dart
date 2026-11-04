import 'package:book_app/core/models/book_model.dart';
import 'package:flutter/foundation.dart';

/// Placeholder price for non-free books, in integer minor units (cents).
///
/// The Google Books API does not give us a reliable sellable price, so the
/// app shows a flat demo price. This is a business decision that must be
/// replaced by a server-side price before real checkout (docs/DECISIONS.md).
const int kPlaceholderPriceCents = 999;

int priceCentsFor(BookModel book) => book.isFree ? 0 : kPlaceholderPriceCents;

/// Formats integer cents as `$X.YY` without floating-point arithmetic.
String formatCents(int cents) {
  final dollars = cents ~/ 100;
  final rest = (cents % 100).toString().padLeft(2, '0');
  return '\$$dollars.$rest';
}

/// In-memory cart shared across the app.
///
/// Kept as a static facade for backwards compatibility with existing call
/// sites; backed by a [ChangeNotifier] so widgets can listen safely.
class CartManager {
  CartManager._();

  static final _CartNotifier _notifier = _CartNotifier();

  static Listenable get listenable => _notifier;

  static List<BookModel> get cartItems => List.unmodifiable(_notifier.items);

  static void addListener(VoidCallback listener) =>
      _notifier.addListener(listener);

  static void removeListener(VoidCallback listener) =>
      _notifier.removeListener(listener);

  static void addToCart(BookModel book) {
    if (isInCart(book)) return;
    _notifier.items.add(book);
    _notifier.notify();
  }

  static void removeFromCart(BookModel book) {
    final before = _notifier.items.length;
    _notifier.items.removeWhere((item) => item.id == book.id);
    if (_notifier.items.length != before) _notifier.notify();
  }

  static void clearCart() {
    if (_notifier.items.isEmpty) return;
    _notifier.items.clear();
    _notifier.notify();
  }

  static bool isInCart(BookModel book) =>
      _notifier.items.any((item) => item.id == book.id);

  static int get totalCents =>
      _notifier.items.fold<int>(0, (sum, book) => sum + priceCentsFor(book));
}

class _CartNotifier extends ChangeNotifier {
  final List<BookModel> items = [];

  void notify() => notifyListeners();
}
