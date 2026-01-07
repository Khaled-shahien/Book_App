import 'package:firebase_core/firebase_core.dart';

class FirebaseInit {
  static bool _started = false;

  static Future<FirebaseApp> ensureInitialized() async {
    if (_started) {
      return Firebase.app();
    }
    _started = true;

    // If already initialized on native side or previous Dart run, avoid duplicate.
    if (Firebase.apps.isNotEmpty) {
      return Firebase.app();
    }

    try {
      // Check if firebase_options.dart exists and use it, otherwise initialize without options
      // This will use the default configuration from native platforms
      return await Firebase.initializeApp();
    } on FirebaseException catch (e) {
      // Ignore duplicate-app, rethrow anything else.
      final msg = e.message ?? '';
      if (e.code == 'duplicate-app' || msg.contains('already exists')) {
        return Firebase.app();
      }
      rethrow;
    }
  }
}
