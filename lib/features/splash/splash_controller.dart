import 'dart:async';

import 'package:book_app/core/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Shows the splash briefly, then routes to Home when a session exists or
/// to Welcome otherwise (previously it always went to Welcome, forcing
/// signed-in users to log in again on every launch).
class SplashController extends GetxController {
  SplashController({
    bool Function()? isSignedIn,
    this.delay = const Duration(seconds: 2),
  }) : _isSignedIn =
           isSignedIn ?? (() => FirebaseAuth.instance.currentUser != null);

  final bool Function() _isSignedIn;
  final Duration delay;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _timer = Timer(delay, _route);
  }

  void _route() {
    var signedIn = false;
    try {
      signedIn = _isSignedIn();
    } catch (_) {
      signedIn = false; // Firebase unavailable: treat as signed out.
    }
    unawaited(Get.offAllNamed<void>(signedIn ? Routes.home : Routes.welcome));
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
