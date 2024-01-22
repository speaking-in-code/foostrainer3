import 'package:flutter_test/flutter_test.dart';
import 'package:ft3/keys.dart';

import 'app_starter.dart';

Function() homeScreenTests(AppStarter appStarter) {
  return () {
    testWidgets('renders home screen', (WidgetTester tester) async {
      await appStarter.startHomeScreen(tester);
      expect(find.text('Start Practice'), findsOneWidget);
      expect(find.text('FoosTrainer'), findsOneWidget);
      expect(find.text('Practice'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.byKey(Keys.moreKey), findsOneWidget);
    });

    testWidgets('navigates to history', (WidgetTester tester) async {
      await appStarter.startHomeScreen(tester);
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      await expectLater(find.byKey(Keys.calendarDatePicker), findsOneWidget);
    });

    testWidgets('navigates to progress', (WidgetTester tester) async {
      await appStarter.startHomeScreen(tester);
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();
      expect(find.text('All Drills'), findsOneWidget);
    });
  };
}
