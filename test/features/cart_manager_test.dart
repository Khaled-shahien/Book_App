import 'package:book_app/features/cart/cart_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  tearDown(CartManager.clearCart);

  test('formatCents is exact (no floating point)', () {
    expect(formatCents(0), r'$0.00');
    expect(formatCents(999), r'$9.99');
    expect(formatCents(1005), r'$10.05');
    expect(formatCents(999 * 3), r'$29.97');
  });

  test('add is idempotent per book id; totals are in cents', () {
    CartManager.addToCart(book(id: 'a'));
    CartManager.addToCart(book(id: 'a'));
    CartManager.addToCart(book(id: 'b'));
    CartManager.addToCart(book(id: 'c', free: true));
    expect(CartManager.cartItems, hasLength(3));
    expect(CartManager.totalCents, 2 * kPlaceholderPriceCents);
  });

  test('notifies listeners only on real changes', () {
    var calls = 0;
    void listener() => calls++;
    CartManager.addListener(listener);
    CartManager.addToCart(book(id: 'a'));
    CartManager.addToCart(book(id: 'a'));
    CartManager.removeFromCart(book(id: 'zzz'));
    CartManager.removeFromCart(book(id: 'a'));
    CartManager.clearCart();
    CartManager.removeListener(listener);
    expect(calls, 2);
  });

  test('cartItems is read-only', () {
    expect(() => CartManager.cartItems.add(book()), throwsUnsupportedError);
  });
}
