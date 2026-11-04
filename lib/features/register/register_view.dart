import 'package:book_app/core/utils/validators.dart';
import 'package:book_app/core/widgets/custom_login_buttom.dart';
import 'package:book_app/core/widgets/custom_textform.dart';
import 'package:book_app/features/login/login_binding.dart';
import 'package:book_app/features/login/login_view.dart';
import 'package:book_app/features/register/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Register',
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
          key: controller.registerFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      const Text(
                        'Please fill your details to signup.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF252525),
                        ),
                      ),

                      const SizedBox(height: 30),

                      CustomTextForm(
                        controller: controller.userController,
                        labelText: 'Username',
                        icon: Icons.verified_user_outlined,
                        validator: Validators.username,
                        autofillHints: const [AutofillHints.username],
                        maxLength: 40,
                      ),

                      const SizedBox(height: 30),

                      CustomTextForm(
                        controller: controller.emailController,
                        labelText: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                        autofillHints: const [AutofillHints.email],
                        maxLength: 254,
                      ),

                      const SizedBox(height: 30),

                      CustomTextForm(
                        controller: controller.passwordController,
                        labelText: 'Password',
                        icon: Icons.lock,
                        isPassword: true,
                        validator: Validators.newPassword,
                        autofillHints: const [AutofillHints.newPassword],
                      ),

                      const SizedBox(height: 30),

                      CustomTextForm(
                        controller: controller.confirmPasswordController,
                        labelText: 'Confirm Password',
                        icon: Icons.lock,
                        isPassword: true,
                        validator: (value) => Validators.confirmPassword(
                          value,
                          controller.passwordController.text,
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => controller.register(),
                      ),

                      const SizedBox(height: 40),

                      Obx(
                        () => CustomLoginButton(
                          text: controller.isLoading.value
                              ? 'Loading...'
                              : 'Sign Up',
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.register,
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
                    'Already a member? ',
                    style: TextStyle(fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Get.off<void>(
                        () => const LoginView(),
                        binding: LoginBinding(),
                      );
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontWeight: FontWeight.w700),
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
