import 'package:ft3/log.dart';
// import 'package:screenshots/screenshots.dart' as screenshots;
import 'package:test/test.dart';

final _log = Log.get('screenshots_test');

void main() {
  // final config = screenshots.Config();

  Future<void> _spin(String where) async {
    _log.info('Spinning at $where');
    while (true) {
      await Future.delayed(Duration(seconds: 1));
    }
  }

  group('FoosTrainer App Screenshots', () {
    test('do nothing', () async {});
  /*
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

    test('drill detailed log', () async {
      await driver.tap(find.text('Progress'));
      await driver.tap(find.text('Log'));
      await driver.tap(find.text('Jun 13, 2020 8:45 AM'));
      await screenshot('Drill-Detailed-Log');
    });
    */
  });
}
