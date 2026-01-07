import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomLoginButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;

  const CustomLoginButton({
    super.key,
    this.text = "Get Started",
    this.backgroundColor = const Color(0xFF121212),
    this.textColor = const Color(0xFFF2F2F2),
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed ?? () => Get.snackbar(
          "Info",
          "Button pressed!",
          snackPosition: SnackPosition.BOTTOM,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
