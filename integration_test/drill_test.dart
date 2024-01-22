import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    final playFinder = find.byIcon(Icons.play_arrow);
    final pauseFinder = find.byIcon(Icons.pause);
    final stopFinder = find.byIcon(Icons.stop);
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
      await appStarter.startHomeScreen(tester);
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

    testWidgets('Runs rollover drill with accuracy on',
        (WidgetTester tester) async {
      await appStarter.startHomeScreen(tester);
      await tester.tapAndSettle(find.text('Start Practice'));
      await tester.tapAndSettle(find.text('Rollover'));
      await tester.tapAndSettle(find.text('Up/Down/Middle'));
      await tester.tapAndSettle(playFinder);
      expect(getAccuracy(), '--');
      await tester.waitFor(find.text('Paused'));
      await tester.waitFor(find.text('Enter Result'));
      expect(find.text('Enter Result'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Missed'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      await tester.tapAndSettle(find.text('Good'));
      await tester.waitFor(find.text('100%'));
    });

    testWidgets('Pauses and resumes drill', (WidgetTester tester) async {
      await appStarter.startHomeScreen(tester);

      await tester.tapAndSettle(find.text('Start Practice'));
      await tester.tapAndSettle(find.text('Brush Pass'));
      await tester.tapAndSettle(
          find.bySemanticsLabel(RegExp(r'Drill Brush Pass: Lane/Wall')));
      await tester.tapAndSettle(find.text('Accuracy Tracking: On'));
      await tester.tapAndSettle(find.text('Off'));
      await tester.tapAndSettle(playFinder);

      await waitForReps(tester, '1');
      expect(playFinder, findsNothing);
      expect(stopFinder, findsOneWidget);

      await tester.tapAndSettle(pauseFinder);
      await tester.waitFor(playFinder);
      expect(pauseFinder, findsNothing);
      expect(stopFinder, findsOneWidget);

      // Should not update clock while paused.
      final origDuration = getDuration();
      await Future.delayed(const Duration(seconds: 2));
      expect(getDuration(), origDuration);

      await tester.tapAndSettle(playFinder);
      await waitForReps(tester, '2');
      expect(getDuration(), greaterThan(origDuration));
    });
  };
}
