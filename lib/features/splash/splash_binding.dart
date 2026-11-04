import 'package:book_app/features/splash/splash_controller.dart';
import 'package:get/get.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Allow tests to pre-register a controller with fakes.
    if (!Get.isRegistered<SplashController>()) {
      Get.put<SplashController>(SplashController());
    }
  }
}
