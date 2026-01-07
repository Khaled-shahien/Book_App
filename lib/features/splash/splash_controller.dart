import 'package:book_app/features/welcome/welcome_page.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAll(() => const WelcomePage()); 
    });
  }
}
