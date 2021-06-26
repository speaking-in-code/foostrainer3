import 'dart:io' show Platform;

import 'package:flutter_driver/flutter_driver.dart';
import 'package:ft3/keys.dart';
import 'package:ft3/log.dart';
import 'package:screenshots/screenshots.dart' as screenshots;
import 'package:test/test.dart';

final _log = Log.get('screenshots_test');

void main() {
  final config = screenshots.Config();
  const kStartPractice = 'Start-Practice';
  const kAccuracyChart = 'Accuracy-Chart';
  const kDrillTypes = 'Drill-Types';
  const kPassTypes = 'Passing-Types';
  const kCalendar = 'Calendar';
  const kRolloverDrill = 'Rollover-Drill';
  const kConfigScreen = 'Config-Screen';
  const kLog = 'Logs-Screen';
  const kBreakdown = 'Drill-Breakdown';

  group('FoosTrainer App Screenshots', () {
    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      driver?.close();
    });

    // Get back to home screen before and after every test.
    setUp(() async {});

    // Get back to home screen before and after every test.
    tearDown(() async {});

    Future<void> screenshot(String name) async {
      await screenshots.screenshot(driver, config, name);
    }

    Future<void> _debugDump(String label) async {
      final tree = await driver.getRenderTree();
      _log.info('$label: ${tree.tree}');
    }

    Future<void> _accuracyChart() async {
      _log.info('Navigating to accuracy screen for Pull: Straight/Middle/Long');
      await driver.tap(find.text('Progress'));
      final accuracyLabel = await driver.getCenter(find.text('Accuracy'));
      _log.info('Accuracy label location: $accuracyLabel');
      _log.info('Tapping on accuracy');
      await driver.tap(find.text('Accuracy'));
      _log.info('Tapping on all drills');
      await driver.tap(find.text('All Drills'));
      _log.info('Tapping on weekly');
      await driver.tap(find.text('Weekly'));
      _log.info('Tapping on drill selection key');
      await driver.tap(find.byValueKey(Keys.drillSelectionKey));
      _log.info('Tapping on pull');
      await driver.tap(find.text('Pull'));
      _log.info('Scrolling to straight/middle/long');
      await driver.scrollIntoView(find.byValueKey('Pull:Straight/Middle/Long'));
      _log.info('Tapping straight/middle/long');
      await driver.tap(find.byValueKey('Pull:Straight/Middle/Long'));
      await driver
          .scrollIntoView(find.byValueKey(Keys.progressChooserCloseKey));
      await driver.tap(find.byValueKey(Keys.progressChooserCloseKey));
      await screenshot(kAccuracyChart);
    }

    test('collect screenshots', () async {
      await driver.waitFor(find.text('Start Practice'));
      await screenshot(kStartPractice);

      await _accuracyChart();

      await driver.tap(find.text('Log'));
      await screenshot(kLog);

      await driver.tap(find.text('Practice'));
      await driver.tap(find.text('Progress'));
      await driver.tap(find.text('Log'));
      await driver.tap(find.text('Jun 13, 2020 8:45 AM'));
      await screenshot(kBreakdown);

      await driver.tap(find.text('Practice'));
      await driver.tap(find.text('History'));
      await screenshot(kCalendar);

      await driver.tap(find.text('Practice'));
      await driver.tap(find.text('Start Practice'));
      await screenshot(kDrillTypes);

      await driver.tap(find.text('Stick Pass'));
      await screenshot(kPassTypes);

      await driver.scrollIntoView(find.text('Rollover'));
      await driver.tap(find.text('Rollover'));
      await driver.scrollIntoView(find.text('Up/Down/Middle'));
      await driver.tap(find.text('Up/Down/Middle'));
      await screenshot(kConfigScreen);

      await driver.tap(find.byValueKey(Keys.playKey));
      await screenshot(kRolloverDrill);
    });
  });
}
