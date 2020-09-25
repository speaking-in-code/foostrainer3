import 'dart:io' show Platform;

import 'package:flutter_driver/flutter_driver.dart';
import 'package:ft3/keys.dart';
import 'package:screenshots/screenshots.dart' as screenshots;
import 'package:test/test.dart';

void main() {
  final config = screenshots.Config();
  const kDrillTypes = 'Drill-Types';
  const kPassTypes = 'Passing-Types';
  const kRolloverTypes = 'Rollover-Types';
  const kRolloverDrill = 'Rollover-Drill';
  const kConfigScreen = 'Config-Screen';
  const kAudioAndFlashScreen = 'Audio-And-Flash-Screen';

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

    test('collect screenshots', () async {
      await driver.waitFor(find.text('Pass'));
      await screenshot(kDrillTypes);

      await driver.tap(find.text('Pass'));
      await screenshot(kPassTypes);

      await driver.tap(find.byType('BackButton'));
      await driver.getText(find.text('Drill Type'));
      await driver.tap(find.text('Rollover'));
      await screenshot(kRolloverTypes);

      await driver.tap(find.text('Up/Down/Middle'));
      await driver.tap(find.text('Drill Time: 10 minutes'));
      await screenshot(kConfigScreen);

      if (Platform.isIOS) {
        await driver.tap(find.text('Signal: Audio'));
        await driver.tap(find.text('Audio and Flash'));
        await screenshot(kAudioAndFlashScreen);
      }

      await driver.tap(find.byValueKey(Keys.playKey));
      await driver.waitFor(find.text('Wait'));
      await screenshot(kRolloverDrill);
    });
  });
}
