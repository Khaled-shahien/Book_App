import 'package:book_app/core/controllers/nav_controller.dart';
import 'package:book_app/core/routes/app_routes.dart';
import 'package:book_app/core/widgets/main_bottom_nav_bar.dart';
import 'package:book_app/features/home/data/controllers/book_controller.dart';
import 'package:book_app/features/login/login_binding.dart';
import 'package:book_app/features/login/login_view.dart';
import 'package:book_app/features/register/register_binding.dart';
import 'package:book_app/features/register/register_view.dart';
import 'package:book_app/features/splash/splash_binding.dart';
import 'package:book_app/features/splash/splash_view.dart';
import 'package:book_app/features/welcome/welcome_page.dart';
import 'package:get/get.dart';

abstract final class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage<void>(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage<void>(name: Routes.welcome, page: () => const WelcomePage()),
    GetPage<void>(
      name: Routes.home,
      page: () => const ModernBottomNavBar(),
      binding: BindingsBuilder<void>(() {
        Get
          ..put(NavController())
          ..put(BookController());
      }),
    ),
    GetPage<void>(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage<void>(
      name: Routes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
  ];
}
