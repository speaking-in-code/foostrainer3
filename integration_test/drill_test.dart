import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ft3/keys.dart';
import 'package:ft3/practice_status_widget.dart';

import 'app_starter.dart';
import 'tap_and_settle.dart';
import 'wait_for.dart';

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

Function() drillTests(AppStarter appStarter) {
  return () {
    final playFinder = find.byKey(Key(Keys.playKey));
    final practiceRepsFinder = find.byKey(PracticeStatusWidget.repsKey);
    final durationFinder = find.byKey(PracticeStatusWidget.elapsedKey);
    final accuracyFinder = find.byKey(PracticeStatusWidget.accuracyKey);
    const maxShotTime = Duration(seconds: 20);

    Future<void> waitForReps(WidgetTester tester, String expected) {
      return tester.waitFor(
          find.descendant(
              of: practiceRepsFinder,
              matching: find.text(expected),
              matchRoot: true),
          timeout: maxShotTime);
    }

    Duration parseDuration(String duration) {
      final re = RegExp(r'^(\d\d):(\d\d):(\d\d)$');
      var match = re.firstMatch(duration)!;
      expect(match, isNotNull, reason: 'Duration "$duration" has bad format.');
      return Duration(
          hours: int.parse(match.group(1)!),
          minutes: int.parse(match.group(2)!),
          seconds: int.parse(match.group(3)!));
    }

    Duration getDuration() {
      String str = (durationFinder.evaluate().first.widget as Text).data!;
      return parseDuration(str);
    }

    String getAccuracy() {
      return (accuracyFinder.evaluate().first.widget as Text).data!;
    }

    testWidgets('Runs drill with accuracy off', (WidgetTester tester) async {
      await tester.pumpWidget(await appStarter.mainApp);
      await tester.tapAndSettle(find.text('Start Practice'));
      await tester.tapAndSettle(find.text('Stick Pass'));
      await tester.tapAndSettle(find.text('Lane/Wall/Bounce'));
      await tester.tapAndSettle(find.text('Accuracy Tracking: On'));
      await tester.tapAndSettle(find.text('Off'));
      await tester.tapAndSettle(playFinder);
      await waitForReps(tester, '0');
      final timeToFirst = Stopwatch()..start();
      await waitForReps(tester, '1');
      timeToFirst.stop();
      expect(timeToFirst.elapsedMilliseconds, greaterThan(1000));
      expect(timeToFirst.elapsedMilliseconds,
          lessThan(maxShotTime.inMilliseconds));
      expect(getDuration(), IsSimilarDuration(timeToFirst.elapsed));
    });

    testWidgets('Runs rollover drill with accuracy on', (WidgetTester tester) async {
      await tester.pumpWidget(await appStarter.mainApp);
      await tester.tapAndSettle(find.text('Start Practice'));
      await tester.tapAndSettle(find.text('Rollover'));
      await tester.tapAndSettle(find.text('Up/Down/Middle'));
      await tester.tapAndSettle(playFinder);
      expect(getAccuracy(), '-');
      await tester.waitFor(find.text('Paused'));
      expect(find.text('Enter Result'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Missed'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      await tester.tapAndSettle(find.text('Good'));
      await waitForReps(tester, '0');
      expect(getAccuracy(), '100%');
    });

    /*
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
  };
}
