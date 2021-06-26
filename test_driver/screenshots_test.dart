import 'package:flutter_driver/flutter_driver.dart';
import 'package:ft3/keys.dart';
import 'package:ft3/log.dart';
import 'package:screenshots/screenshots.dart' as screenshots;
import 'package:test/test.dart';

final _log = Log.get('screenshots_test');

void main() {
  final config = screenshots.Config();

  Future<void> _spin(String where) async {
    _log.info('Spinning at $where');
    while (true) {
      await Future.delayed(Duration(seconds: 1));
    }
  }

  group('FoosTrainer App Screenshots', () {
    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      _log.info('Connecting to flutter driver');
      driver = await FlutterDriver.connect(printCommunication: true);
      _log.info('Waiting for first frame');
      await driver.waitUntilFirstFrameRasterized();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      driver?.close();
    });

    // Nav back to home screen before each screenshot.
    setUp(() async {
      await driver.tap(find.text('Practice'));
    });

    Future<void> screenshot(String name) async {
      await screenshots.screenshot(driver, config, name);
    }

    Future<void> _debugDump(String label) async {
      final tree = await driver.getRenderTree();
      _log.info('$label: ${tree.tree}');
    }

    test('start practice', () async {
      await screenshot('Start-Practice');
    });

    test('accuracy chart', () async {
      await driver.tap(find.text('Progress'));
      await driver.tap(find.text('Accuracy'));
      await driver.tap(find.text('All Drills'));
      await driver.tap(find.text('Weekly'));
      await driver.tap(find.byValueKey(Keys.drillSelectionKey));
      await driver.tap(find.text('Pull'));
      await driver.scrollIntoView(find.byValueKey('Pull:Straight/Middle/Long'));
      await driver.tap(find.byValueKey('Pull:Straight/Middle/Long'));
      await driver
          .scrollIntoView(find.byValueKey(Keys.progressChooserCloseKey));
      await driver.tap(find.byValueKey(Keys.progressChooserCloseKey));
      await screenshot('Accuracy-Chart');
    });

    test('drill logs', () async {
      await driver.tap(find.text('Progress'));
      await driver.tap(find.text('Log'));
      await screenshot('Logs-Screen');
    });

    test('drill detailed log', () async {
      await driver.tap(find.text('Progress'));
      await driver.tap(find.text('Log'));
      await driver.tap(find.text('Jun 13, 2020 8:45 AM'));
      await screenshot('Drill-Detailed-Log');
    });

    test('calendar', () async {
      await driver.tap(find.text('History'));
      await screenshot('Calendar');
    });

    test('drill types', () async {
      await driver.tap(find.text('Start Practice'));
      await screenshot('Drill-Types');
      await driver.tap(find.byTooltip('Back'));
    });

    test('pass types', () async {
      await driver.tap(find.text('Start Practice'));
      await driver.tap(find.text('Stick Pass'));
      await screenshot('Passing-Types');
      await driver.tap(find.byTooltip('Back'));
    });

    test('config screen', () async {
      await driver.tap(find.text('Start Practice'));
      await driver.scrollIntoView(find.text('Rollover'));
      await driver.tap(find.text('Rollover'));
      await driver.scrollIntoView(find.text('Up/Down/Middle'));
      await driver.tap(find.text('Up/Down/Middle'));
      await screenshot('Config-Screen');
      await driver.tap(find.byTooltip('Back'));
      await driver.tap(find.byTooltip('Back'));
    });

    test('rollover drill', () async {
      await driver.tap(find.text('Start Practice'));
      await driver.scrollIntoView(find.text('Rollover'));
      await driver.tap(find.text('Rollover'));
      await driver.scrollIntoView(find.text('Up/Down/Middle'));
      await driver.tap(find.text('Up/Down/Middle'));
      await driver.tap(find.byValueKey(Keys.playKey));
      await screenshot('Rollover-Drill');
    });
  });
}
