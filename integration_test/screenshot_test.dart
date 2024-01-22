/// Takes screenshots for upload to app store.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fbtl_screenshots/fbtl_screenshots.dart';

import 'app_starter.dart';
import 'tap_and_settle.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final _screenshots = FBTLScreenshots()..connect();
  final appStarter = AppStarter(fakeDrillScreen: true);

  Future<void> _screenshot(WidgetTester tester, String name) async {
    await _screenshots.takeScreenshot(tester, name);
  }

  testWidgets('Home Screen', (WidgetTester tester) async {
    await tester.pumpWidget(await appStarter.mainApp);
    await _screenshot(tester, '01-home-screen');
  });

  testWidgets('Drill detailed log', (WidgetTester tester) async {
    await tester.pumpWidget(await appStarter.mainApp);
    await tester.tapAndSettle(find.text('Progress'));
    await tester.tapAndSettle(find.text('Log'));
    await tester.tapAndSettle(find.textContaining('Jun 13, 2020 8:45'));
    await _screenshot(tester, 'Drill-Detailed-Log');
  });

  Future<void> _closeModal(WidgetTester tester) async {
    final point = tester.getCenter(find.text('Accuracy').first);
    await tester.tapAt(point);
    await tester.pumpAndSettle();
  }

  testWidgets('Accuracy chart', (WidgetTester tester) async {
    await tester.pumpWidget(await appStarter.mainApp);

    // Show weekly progress.
    await tester.tapAndSettle(find.text('Progress'));
    await tester.tapAndSettle(find.text('Accuracy'));
    await tester.tapAndSettle(find.text('All Drills'));
    await tester.tapAndSettle(find.text('Weekly'));

    // Focus on a specific pull shot drill.
    await tester.tapAndSettle(
        find.bySemanticsLabel(RegExp(r'Select All Drills')));
    await tester.tapAndSettle(find.text('Pull'));
    final scrollable = find.descendant(of: find.byKey(Key('Drill Type List: Pull')),
        matching: find.byType(Scrollable));
    expect(scrollable, findsOneWidget);
    final pullDrill =find.bySemanticsLabel(RegExp(r'Drill Pull: Straight/Middle/Long'));
    await tester.scrollUntilVisible(pullDrill, 20, scrollable: scrollable);
    await tester.tapAndSettle(pullDrill);
    await _closeModal(tester);

    await _screenshot(tester, 'Accuracy-Chart');
  });
}
