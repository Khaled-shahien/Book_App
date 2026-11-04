import 'package:book_app/core/widgets/custom_textform.dart';
import 'package:book_app/core/widgets/error_state_view.dart';
import 'package:book_app/features/splash/splash_controller.dart';
import 'package:book_app/features/welcome/welcome_page.dart';
import 'package:book_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  testWidgets('signed-out launch goes from splash to Welcome', (tester) async {
    Get.put(SplashController(isSignedIn: () => false));
    await tester.pumpWidget(const BookApp());
    expect(find.byType(WelcomePage), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('Firebase being unavailable is treated as signed out', (
    tester,
  ) async {
    Get.put(SplashController(isSignedIn: () => throw StateError('no app')));
    await tester.pumpWidget(const BookApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('ErrorStateView shows message and retries', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorStateView(message: 'Offline', onRetry: () => retries++),
        ),
      ),
    );
    expect(find.text('Offline'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });

  testWidgets('password field toggles visibility', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomTextForm(
            labelText: 'Password',
            icon: Icons.lock,
            isPassword: true,
          ),
        ),
      ),
    );
    EditableText field() => tester.widget(find.byType(EditableText));
    expect(field().obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(field().obscureText, isFalse);
  });

  testWidgets('form validation blocks invalid email', (tester) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: key,
            child: CustomTextForm(
              labelText: 'Email',
              icon: Icons.email,
              validator: (v) =>
                  (v ?? '').contains('@') ? null : 'Please enter a valid email',
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'nope');
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });
}
