import 'package:book_app/core/widgets/custom_login_buttom.dart';
import 'package:book_app/core/widgets/custom_textform.dart';
import 'package:book_app/features/login/login_controller.dart';
import 'package:book_app/features/register/register_binding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../register/register_view.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Get Started",
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: controller.loginFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      const Text(
                        "Please fill your details to login.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF252525),
                        ),
                      ),

                      const SizedBox(height: 30),

                      CustomTextForm(
                        controller: controller.emailController,
                        labelText: "Email",
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your email';
                          }
                          if (!GetUtils.isEmail(value!)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      CustomTextForm(
                        controller: controller.passwordController,
                        labelText: "Password",
                        icon: Icons.lock,
                        isPassword: true,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your password';
                          }
                          if (value!.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 40),

                      Obx(
                        () => CustomLoginButton(
                          text: controller.isLoading.value
                              ? "Loading..."
                              : "Login",
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.login,
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: controller.goToForgotPassword,
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Get.off(
                    () => const RegisterView(),
                    binding: RegisterBinding(),
                  );
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
