
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:screenshots/screenshots.dart' as screenshots;
import 'package:test/test.dart';

void main() {
  final config = screenshots.Config();
  final drillTypes = 'Drill-Types';
  final passTypes = 'Passing-Types';
  final rolloverTypes = 'Rollover-Types';
  final rolloverDrill = 'Rollover-Drill';
  // Slight delay because otherwise we hit
  // https://github.com/flutter/flutter/issues/35521.
  final renderingDelayTime = Duration(seconds: 1);

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
      await screenshot(drillTypes);

      await driver.tap(find.text('Pass'));
      await screenshot(passTypes);

      await driver.tap(find.byType('BackButton'));
      await driver.getText(find.text('Drill Type'));
      await driver.tap(find.text('Rollover'));
      await screenshot(rolloverTypes);

      await driver.tap(find.text('Up/Down/Middle'));
      await driver.waitFor(find.text('Wait'));
      sleep(renderingDelayTime);
      await screenshot(rolloverDrill);
    });
  });
}
