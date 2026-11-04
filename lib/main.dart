import 'dart:ui';

import 'package:book_app/core/firebase/firebase_init.dart';
import 'package:book_app/core/routes/app_pages.dart';
import 'package:book_app/core/routes/app_routes.dart';
import 'package:book_app/core/theme/app_theme.dart';
import 'package:book_app/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Install error handlers before anything that can throw.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.reportError(
      details.exception,
      details.stack,
      reason: 'FlutterError',
      fatal: true,
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.reportError(error, stack, reason: 'Uncaught', fatal: true);
    return true;
  };

  try {
    await FirebaseInit.ensureInitialized();
  } catch (e, st) {
    // Keep the app usable (book browsing works without Firebase); auth
    // screens surface their own errors.
    AppLogger.reportError(e, st, reason: 'Firebase init failed');
  }

  runApp(const BookApp());
}

class BookApp extends StatelessWidget {
  const BookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Book App',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Screens still hardcode light surfaces/text colors, which made dark
      // mode unreadable (white text on white cards). Light-only until the
      // screens consume theme tokens — see docs/DECISIONS.md (D-005).
      themeMode: ThemeMode.light,
    );
  }
}
