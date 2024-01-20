/// Takes screenshots for upload to app store.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fbtl_screenshots/fbtl_screenshots.dart';

import 'app_starter.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final _screenshots = FBTLScreenshots()..connect();
  final appStarter = AppStarter();

  Future<void> _screenshot(WidgetTester tester, String name) async {
    await _screenshots.takeScreenshot(tester, name);
  }

  Future<void> _tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('Home Screen', (WidgetTester tester) async {
    await tester.pumpWidget(await appStarter.mainApp);
    await _screenshot(tester, '01-home-screen');
  });

  testWidgets('Drill detailed log', (WidgetTester tester) async {
    await tester.pumpWidget(await appStarter.mainApp);
    await _tapAndSettle(tester, find.text('Progress'));
    await _tapAndSettle(tester, find.text('Log'));
    await _tapAndSettle(tester, find.textContaining('Jun 13, 2020 8:45'));
    await _screenshot(tester, 'Drill-Detailed-Log');
  });

  testWidgets('Accuracy chart', (WidgetTester tester) async {
    await tester.pumpWidget(await appStarter.mainApp);
    await _tapAndSettle(tester, find.text('Progress'));
    await _tapAndSettle(tester, find.text('Accuracy'));
    await _tapAndSettle(tester, find.text('All Drills'));
    await _tapAndSettle(tester, find.text('Weekly'));
    await _tapAndSettle(tester, find.text('Accuracy'));
    // TODO(beaton): fix this semantics label line, this is the one that isn't matching right now.
    // Also maybe work on faster ways to debug this code.
    await _tapAndSettle(tester, find.bySemanticsLabel('Select All Drills'));
    await _tapAndSettle(tester, find.text('Pull'));
    await tester.scrollUntilVisible(find.text('Straight/Middle/Long'), 20);
    await tester.pumpAndSettle();
    await _tapAndSettle(tester, find.text('Accuracy'));
    await _screenshot(tester, 'Accuracy-Chart');
  });
}

