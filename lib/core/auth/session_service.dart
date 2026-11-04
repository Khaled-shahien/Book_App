import 'package:book_app/core/routes/app_routes.dart';
import 'package:book_app/features/cart/cart_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Ends the session and clears every piece of per-user in-memory state.
abstract final class SessionService {
  static Future<void> signOut({FirebaseAuth? auth}) async {
    // Leave the signed-in screens first so nothing rebuilds with a null user.
    // This also removes Home/Account routes and their controllers.
    await Get.offAllNamed<void>(Routes.login);
    // The cart is per-user; never leak it to the next account.
    CartManager.clearCart();
    await (auth ?? FirebaseAuth.instance).signOut();
  }
}

/// Account deletion (required by App Store 5.1.1(v) and Google Play).
abstract final class AccountDeletionService {
  /// Firebase rejects `User.delete()` when the last sign-in is older than
  /// about 5 minutes. Check that up front so the profile is never deleted
  /// while the Auth account survives.
  static const recentLoginWindow = Duration(minutes: 5);

  /// Deletes the user's Firestore profile, then the Auth account.
  ///
  /// Throws [FirebaseAuthException] with code `requires-recent-login` when
  /// the session is too old; nothing is deleted in that case.
  static Future<void> deleteCurrentUser({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    DateTime Function() now = DateTime.now,
  }) async {
    final user = (auth ?? FirebaseAuth.instance).currentUser;
    if (user == null) return;

    final lastSignIn = user.metadata.lastSignInTime;
    if (lastSignIn == null ||
        now().difference(lastSignIn) > recentLoginWindow) {
      throw FirebaseAuthException(code: 'requires-recent-login');
    }

    // The profile must go first: the security rules need request.auth to
    // allow the delete. A Cloud Function on auth user deletion is the
    // recommended long-term backstop (docs/DECISIONS.md D-008).
    await (firestore ?? FirebaseFirestore.instance)
        .collection('users')
        .doc(user.uid)
        .delete();
    await user.delete();
    CartManager.clearCart();
    await Get.offAllNamed<void>(Routes.welcome);
  }
}
