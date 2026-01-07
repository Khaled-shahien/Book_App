

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final loginFormKey = GlobalKey<FormState>();

  final isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void login() async {
  FocusManager.instance.primaryFocus?.unfocus();

  if (!loginFormKey.currentState!.validate()) return;

  isLoading.value = true;

  try {
    await _auth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    Get.offAllNamed('/home');

  } on FirebaseAuthException catch (e) {
    String message = 'Login failed';

    if (e.code == 'user-not-found') {
      message = 'No user found for that email';
    } else if (e.code == 'wrong-password') {
      message = 'Wrong password provided';
    }

    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  } catch (e) {
    Get.snackbar(
      "Error",
      "An unexpected error occurred",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  } finally {
    isLoading.value = false;
  }
}



  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void goToForgotPassword() {
    Get.snackbar(
      'Info',
      'Forgot Password screen not implemented yet',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
