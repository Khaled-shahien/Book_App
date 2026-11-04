import 'package:book_app/core/routes/app_routes.dart';
import 'package:book_app/features/cart/cart_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Ends the session and clears every piece of per-user in-memory state.
abstract final class SessionService {
  static Future<void> signOut({FirebaseAuth? auth}) async {
    await (auth ?? FirebaseAuth.instance).signOut();
    // The cart is per-user; never leak it to the next account.
    CartManager.clearCart();
    // Removes Home/Account routes and their controllers (cached searches).
    await Get.offAllNamed<void>(Routes.login);
  }
}

/// Account deletion (required by App Store 5.1.1(v) and Google Play).
abstract final class AccountDeletionService {
  /// Deletes the user's Firestore profile, then the Auth account.
  ///
  /// Throws [FirebaseAuthException] with code `requires-recent-login` when
  /// the session is too old; the caller should ask the user to sign in again.
  static Future<void> deleteCurrentUser({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) async {
    final user = (auth ?? FirebaseAuth.instance).currentUser;
    if (user == null) return;
    await (firestore ?? FirebaseFirestore.instance)
        .collection('users')
        .doc(user.uid)
        .delete();
    await user.delete();
    CartManager.clearCart();
    await Get.offAllNamed<void>(Routes.welcome);
  }
}
