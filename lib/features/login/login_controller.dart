import 'dart:async';

import 'package:book_app/core/auth/auth_error_mapper.dart';
import 'package:book_app/core/routes/app_routes.dart';
import 'package:book_app/core/utils/app_logger.dart';
import 'package:book_app/core/utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  LoginController({FirebaseAuth? auth}) : _authOverride = auth;

  final FirebaseAuth? _authOverride;
  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  Future<void> login() async {
    if (isLoading.value) return; // guard against double submit
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        // Never trim passwords: leading/trailing spaces are significant.
        password: passwordController.text,
      );
      unawaited(Get.offAllNamed<void>(Routes.home));
    } on FirebaseAuthException catch (e) {
      _showError(AuthErrorMapper.message(e.code));
    } catch (e, st) {
      AppLogger.reportError(e, st, reason: 'login failed');
      _showError(AuthErrorMapper.message('unknown'));
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  /// Sends a password-reset email to the address in the email field.
  ///
  /// Always shows the same confirmation so the app does not reveal whether
  /// an account exists for that address.
  Future<void> goToForgotPassword() async {
    if (isLoading.value) return;
    final email = emailController.text.trim();
    final error = Validators.email(email);
    if (error != null) {
      _showError('Enter your email above, then tap "Forgot Password?" again.');
      return;
    }
    isLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showInfo();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        _showInfo();
      } else {
        _showError(AuthErrorMapper.message(e.code));
      }
    } catch (e, st) {
      AppLogger.reportError(e, st, reason: 'password reset failed');
      _showError(AuthErrorMapper.message('unknown'));
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void _showInfo() {
    Get.snackbar(
      'Check your inbox',
      'If an account exists for that email, a reset link has been sent.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
