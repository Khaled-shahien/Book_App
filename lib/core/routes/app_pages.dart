import 'package:book_app/features/login/login_binding.dart';
import 'package:book_app/features/login/login_view.dart';
import 'package:book_app/features/register/register_binding.dart';
import 'package:book_app/features/register/register_view.dart';
import 'package:book_app/features/splash/splash_binding.dart';
import 'package:book_app/features/welcome/welcome_page.dart';
import 'package:get/get.dart';
import '../../features/splash/splash_view.dart';
import 'package:book_app/core/widgets/main_bottom_nav_bar.dart';
import 'package:book_app/core/controllers/nav_controller.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(name: Routes.welcome, page: () => const WelcomePage()),
    GetPage(
      name: Routes.home,
      page: () => const ModernBottomNavBar(),
      binding: BindingsBuilder(() {
        Get.put(NavController());
      }),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
  ];
}
