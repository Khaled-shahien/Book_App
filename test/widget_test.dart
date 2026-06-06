import 'package:book_app/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('BookApp builds and completes the splash timer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BookApp());
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(BookApp), findsOneWidget);
  });
}
