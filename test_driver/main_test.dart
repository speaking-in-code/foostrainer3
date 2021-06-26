import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:ft3/keys.dart';
import 'package:test/test.dart';

class IsSimilarDuration extends Matcher {
  Duration _expected;

  IsSimilarDuration(this._expected);

  @override
  Description describe(Description description) {
    description.add('Expect duration close to $_expected');
    return description;
  }

  @override
  bool matches(item, Map matchState) {
    Duration found = item as Duration;
    return (found.inSeconds - _expected.inSeconds).abs() <= 3;
  }
}

void main() {
  group('FoosTrainer App', () {
    final practiceRepsFinder = find.byValueKey(Keys.repsKey);
    final durationFinder = find.byValueKey(Keys.elapsedKey);
    final playFinder = find.byValueKey(Keys.playKey);
    final pauseFinder = find.byValueKey(Keys.pauseKey);
    const drillWaitTimeout = Duration(seconds: 20);
    // 15 second timeout, plus 3 seconds for reset between shots, plus some
    // extra because emulators are slow sometimes.
    const maxShotTime = Duration(seconds: 20);

    FlutterDriver driver;

    Future<bool> isPresent(SerializableFinder finder) async {
      try {
        await driver.waitFor(finder);
        return true;
      } catch (exception) {
        return false;
      }
    }

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
      await isPresent(find.text('Start Practice'));
      //expect(find.text('Start Practice'), is
      await driver.tap(find.byValueKey(Keys.moreKey));
      for (int i = 0; i < 3; ++i) {
        print('Tapping on version: $i');
        await driver.tap(find.text('Version: '));
      }
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      driver?.close();
    });

    // Get back to home screen before and after every test.
    setUp(() async {});

    // Get back to home screen before and after every test.
    tearDown(() async {});

    test('does nothing', () async {});

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

    /*
    Future<void> navigatePracticeToHome() async {
      await driver.tap(find.byType('BackButton'));
      await driver.tap(find.byType('BackButton'));
      await driver.tap(find.byType('BackButton'));
      await driver.getText(find.text('Drill Type'));
    }

    test('runs passing drill', () async {
      await driver.tap(find.text('Pass'));
      await driver.tap(find.text('Lane/Wall/Bounce'));
      await driver.tap(playFinder);
      await waitForReps('0');
      var timeToFirst = Stopwatch();
      timeToFirst.start();
      await waitForReps('1');
      timeToFirst.stop();
      expect(timeToFirst.elapsedMilliseconds, greaterThan(1000));
      expect(timeToFirst.elapsedMilliseconds,
          lessThan(maxShotTime.inMilliseconds));
      Duration fromUi = parseDuration(await getDuration());
      expect(fromUi, IsSimilarDuration(timeToFirst.elapsed));
      await navigatePracticeToHome();
    });

    test('runs rollover drill', () async {
      await driver.tap(find.text('Rollover'));
      await driver.tap(find.text('Up/Down/Middle'));
      await driver.tap(playFinder);
      sleep(Duration(seconds: 1));
      await waitForReps('0');
      var timeToFirst = Stopwatch();
      timeToFirst.start();
      await waitForReps('1');
      timeToFirst.stop();
      expect(timeToFirst.elapsedMilliseconds, greaterThan(1000));
      expect(timeToFirst.elapsedMilliseconds,
          lessThan(maxShotTime.inMilliseconds));
      Duration fromUi = parseDuration(await getDuration());
      expect(fromUi, IsSimilarDuration(timeToFirst.elapsed));
      await navigatePracticeToHome();
    });

    test('pause and resume work', () async {
      await driver.getText(find.text('Drill Type'));
      await driver.tap(find.text('Rollover'));
      await driver.tap(find.text('Up/Down'));
      await driver.tap(playFinder);
      await waitForReps('0');
      await waitForReps('1');

      // Hit the pause button
      driver.tap(pauseFinder);
      await driver.getText(find.text('Paused'));
      Duration orig = parseDuration(await getDuration());
      sleep(Duration(seconds: 5));
      Duration afterSleep = parseDuration(await getDuration());
      expect(afterSleep, equals(orig));
      await waitForReps('1');

      // Hit the play button
      driver.tap(playFinder);
      sleep(Duration(seconds: 5));
      var afterPlay = parseDuration(await getDuration());
      expect(afterPlay.inSeconds, greaterThan(orig.inSeconds));
      await navigatePracticeToHome();
    });

     */
  });
}
