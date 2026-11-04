import 'dart:async';

import 'package:book_app/core/auth/auth_error_mapper.dart';
import 'package:book_app/core/routes/app_routes.dart';
import 'package:book_app/core/utils/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  RegisterController({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _authOverride = auth,
      _firestoreOverride = firestore;

  final FirebaseAuth? _authOverride;
  final FirebaseFirestore? _firestoreOverride;
  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  final userController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final registerFormKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  Future<void> register() async {
    if (isLoading.value) return; // guard against double submit
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(registerFormKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    final name = userController.text.trim();
    final email = emailController.text.trim();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: passwordController.text, // never trim passwords
      );
      final user = credential.user;
      if (user == null) {
        _showError(AuthErrorMapper.message('unknown'));
        return;
      }

      // The account now exists. Profile setup failures must not strand the
      // user on the form (retrying would fail with email-already-in-use),
      // so they are reported but do not block navigation.
      try {
        await user.updateDisplayName(name);
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'phone': '',
          'ordersCount': 0,
          'favoritesCount': 0,
          'reviewsCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e, st) {
        AppLogger.reportError(e, st, reason: 'profile creation failed');
      }

      Get.snackbar(
        'Welcome!',
        'Your account has been created.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
      unawaited(Get.offAllNamed<void>(Routes.home));
    } on FirebaseAuthException catch (e) {
      _showError(AuthErrorMapper.message(e.code));
    } catch (e, st) {
      AppLogger.reportError(e, st, reason: 'register failed');
      _showError(AuthErrorMapper.message('unknown'));
    } finally {
      if (!isClosed) isLoading.value = false;
    }
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
    userController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void goToLogin() => Get.back<void>();
}
