import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

class IsSimilarDuration extends Matcher {
  Duration _expected;

  IsSimilarDuration(Duration this._expected);

  @override
  Description describe(Description description) {
    description.add('Expect duration close to $_expected');
    return description;
  }

  @override
  bool matches(item, Map matchState) {
    Duration found = item as Duration;
    return (found.inSeconds - _expected.inSeconds).abs() <= 1;
  }
}

void main() {
  group('FoosTrainer App', () {
    final practiceRepsFinder = find.byValueKey('repsKey');
    final durationFinder = find.byValueKey('elapsedKey');
    const drillWaitTimeout = Duration(seconds: 20);
    const uiPresentTimeout = Duration(milliseconds: 200);

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

    Future<void> waitForReps(String expected) {
      return driver.waitFor(
          find.descendant(
              of: practiceRepsFinder,
              matching: find.text(expected),
              matchRoot: true),
          timeout: drillWaitTimeout);
    }

    Future<String> getDuration() {
      return driver.getText(durationFinder);
    }

    Duration parseDuration(String duration) {
      final re = RegExp(r'^(\d\d):(\d\d):(\d\d)$');
      var match = re.firstMatch(duration);
      expect(match, isNotNull, reason: 'Duration "$duration" has bad format.');
      return Duration(
          hours: int.parse(match.group(1)),
          minutes: int.parse(match.group(2)),
          seconds: int.parse(match.group(3)));
    }

    test('runs passing drill', () async {
      await driver.getText(find.text('Drill Type'));
      await driver.tap(find.text('Pass'));
      await driver.tap(find.text('Lane/Wall/Bounce'));
      await waitForReps('0');
      var timeToFirst = Stopwatch();
      timeToFirst.start();
      await waitForReps('1');
      timeToFirst.stop();
      expect(timeToFirst.elapsedMilliseconds, greaterThan(1000));
      expect(timeToFirst.elapsedMilliseconds, lessThan(15000));
      Duration fromUi = parseDuration(await getDuration());
      expect(fromUi, IsSimilarDuration(timeToFirst.elapsed));
      await driver.tap(find.byType('BackButton'));
      await driver.tap(find.byType('BackButton'));
      await driver.getText(find.text('Drill Type'));
    });
  });
}
