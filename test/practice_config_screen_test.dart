import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ft3/drill_data.dart';
import 'package:ft3/practice_config_screen.dart';
import 'package:ft3/static_drills.dart';
// import 'package:mocking/main.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:ft3/app_rater.dart';
import 'package:ft3/practice_background.dart';

import 'practice_config_screen_test.mocks.dart';

@GenerateMocks([AppRater, PracticeBackground])
void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final appRater = MockAppRater();
  final practice = MockPracticeBackground();
  DrillData? runningDrill;
  when(practice.startPractice(any)).thenAnswer((invocation) async {
    runningDrill = invocation.positionalArguments[0];
  });
  final drills = await StaticDrills.load();

  MaterialApp _buildApp() {
    final drillData = drills.getDrill('Stick Pass:Lane/Wall')!;
    return MaterialApp(onGenerateRoute: (settings) {
      return MaterialPageRoute(
          settings: RouteSettings(arguments: drillData.copy()),
          builder: (context) {
            return PracticeConfigScreen(appRater: appRater, practice: practice);
          });
    });
  }

  Future<void> _startDrill(WidgetTester tester) async {
    final playFinder = find.byIcon(Icons.play_arrow);
    await tester.tap(playFinder);
    await tester.pumpAndSettle();
  }

  testWidgets('Starts Practice', (tester) async {
    await tester.pumpWidget(_buildApp());
    await _startDrill(tester);
    expect(runningDrill, isNotNull);
    expect(runningDrill!.fullName, 'Stick Pass:Lane/Wall');
    expect(runningDrill!.displayName, 'Stick Pass: Lane/Wall');
    expect(runningDrill!.possessionSeconds, 10);
    expect(runningDrill!.tempo, Tempo.RANDOM);
    expect(runningDrill!.practiceMinutes, 10);
    expect(runningDrill!.tracking, true);
  });

  testWidgets('Changes Tempo to slow', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.tap(find.text('Tempo: Random'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Slow'));
    await tester.pumpAndSettle();
    await _startDrill(tester);
    expect(runningDrill, isNotNull);
    expect(runningDrill!.tempo, Tempo.SLOW);
  });

  testWidgets('Changes Tempo to fast', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.tap(find.text('Tempo: Random'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fast'));
    await tester.pumpAndSettle();
    await _startDrill(tester);
    expect(runningDrill, isNotNull);
    expect(runningDrill!.tempo, Tempo.FAST);
  });

  testWidgets('Changes Tempo back to random', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.tap(find.text('Tempo: Random'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fast'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Random'));
    await tester.pumpAndSettle();
    await _startDrill(tester);
    expect(runningDrill, isNotNull);
    expect(runningDrill!.tempo, Tempo.RANDOM);
  });

  Future<void> _drillTimeTest(
      WidgetTester tester, double offset, String text, int value) async {
    await tester.pumpWidget(_buildApp());
    await tester.tap(find.text('Drill Time: 10 minutes'));
    await tester.pumpAndSettle();
    await tester.tapSlider(
        find.byKey(PracticeConfigScreen.drillTimeSliderKey), offset);
    await tester.pumpAndSettle();
    Text drillTimeText =
        tester.firstWidget(find.byKey(PracticeConfigScreen.drillTimeTextKey));
    expect(drillTimeText.data, text);
    await _startDrill(tester);
    expect(runningDrill, isNotNull);
    expect(runningDrill!.practiceMinutes, value);
  }

  testWidgets('Changes drill time', (tester) async {
    await _drillTimeTest(tester, 0, 'Drill Time: 5 minutes', 5);
    await _drillTimeTest(tester, 50, 'Drill Time: 10 minutes', 10);
    await _drillTimeTest(tester, 150, 'Drill Time: 15 minutes', 15);
    await _drillTimeTest(tester, 300, 'Drill Time: 25 minutes', 25);
    await _drillTimeTest(tester, 750, 'Drill Time: 60 minutes', 60);
  });

  testWidgets('Accuracy tracking on by default', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.tap(find.text('Accuracy Tracking: On'));
    await tester.pumpAndSettle();
    await _startDrill(tester);
    expect(runningDrill, isNotNull);
    expect(runningDrill!.tracking, true);
  });

  testWidgets('Turns off accuracy tracking', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.tap(find.text('Accuracy Tracking: On'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Off'));
    await tester.pumpAndSettle();
    await _startDrill(tester);
    expect(runningDrill, isNotNull);
    expect(runningDrill!.tracking, false);
  });
}

extension SlideTo on WidgetTester {
  Future<void> tapSlider(Finder slider, double offset,
      {double paddingOffset = 24.0}) async {
    final zeroPoint = this.getTopLeft(slider) +
        Offset(paddingOffset, this.getSize(slider).height / 2);
    final calculatedOffset = zeroPoint.translate(offset, 0);
    await this.tapAt(calculatedOffset);
  }
}
