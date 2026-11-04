import 'package:firebase_core/firebase_core.dart';

/// Idempotent Firebase initialization.
///
/// Uses the native config files (google-services.json /
/// GoogleService-Info.plist), which are git-ignored and provided per
/// environment — see docs/HUMAN_ACTIONS.md.
abstract final class FirebaseInit {
  static Future<FirebaseApp>? _pending;

  static Future<FirebaseApp> ensureInitialized() {
    if (Firebase.apps.isNotEmpty) return Future.value(Firebase.app());
    // Share one in-flight init; reset on failure so a later call can retry.
    return _pending ??= _init().catchError((Object e) {
      _pending = null;
      throw e;
    });
  }

  static Future<FirebaseApp> _init() async {
    try {
      return await Firebase.initializeApp();
    } on FirebaseException catch (e) {
      if (e.code == 'duplicate-app') return Firebase.app();
      rethrow;
    }
  }
}
