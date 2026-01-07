import 'package:book_app/core/widgets/custom_login_buttom.dart';
import 'package:book_app/features/login/login_binding.dart';
import 'package:book_app/features/login/login_view.dart';
import 'package:book_app/features/register/register_binding.dart';
import 'package:book_app/features/register/register_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 450,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/home.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -70,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        "assets/images/splash_screen.png",
                        width: 140,
                        height: 140,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 100),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Read more and stress less with our online book shopping app. "
                  "Shop from anywhere you are and discover titles that you love. "
                  "Happy reading!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 80),

              CustomLoginButton(
                onPressed: () {
                  Get.to(() => const LoginView(), binding: LoginBinding());
                },
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Get.to(
                    () => const RegisterView(),
                    binding: RegisterBinding(),
                  );
                },
                child: const Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121212),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
