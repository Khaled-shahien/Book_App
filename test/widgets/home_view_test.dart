import 'package:book_app/core/error/failure.dart';
import 'package:book_app/core/widgets/error_state_view.dart';
import 'package:book_app/features/home/data/controllers/book_controller.dart';
import 'package:book_app/features/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../features/book_controller_test.dart' show FakeBookServices;
import '../helpers/fixtures.dart';

void main() {
  late FakeBookServices fake;

  setUp(() {
    Get.testMode = true;
    fake = FakeBookServices();
  });
  tearDown(Get.reset);

  // Images are not loaded in tests; use a tall surface so lazy lists build.
  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Created inside the test so futures run in the fake-async zone.
    Get.put(BookController(bookServices: fake, initialQuery: 'init'));
    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
  }

  testWidgets('shows a loader, then the books', (tester) async {
    await pumpHome(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    fake.complete('init', [book()]);
    await tester.pump();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Clean Code'), findsWidgets);
  });

  testWidgets('shows an error with Retry that re-fetches', (tester) async {
    await pumpHome(tester);
    fake.fail('init', const NetworkFailure());
    await tester.pump();
    await tester.pump();

    expect(find.byType(ErrorStateView), findsOneWidget);
    expect(find.text(const NetworkFailure().message), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(fake.queries, ['init', 'init']);
    fake.complete('init', [book()]);
    await tester.pump();
    await tester.pump();
    expect(find.byType(ErrorStateView), findsNothing);
  });

  testWidgets('shows the empty state when nothing matches', (tester) async {
    await pumpHome(tester);
    fake.complete('init', const []);
    await tester.pump();
    await tester.pump();
    expect(find.text('No books found'), findsOneWidget);
  });
}
