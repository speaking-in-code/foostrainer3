import 'package:flutter/material.dart';

/// Tests navigation and rendering of the practice config screen.
import 'package:flutter_test/flutter_test.dart';
import 'package:ft3/main.dart';
import 'package:ft3/practice_config_screen.dart';

void main() {
  Future<void> _render(WidgetTester tester) async {
    MainApp mainApp = MainApp();
    await tester.pumpWidget(mainApp);
    await tester.pump();
    await tester.tap(find.text('Rollover'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Up/Down/Middle'));
    await tester.pumpAndSettle();
  }

  Text getDrillTime() {
    return find
        .byKey(PracticeConfigScreen.drillTimeTextKey)
        .evaluate()
        .single
        .widget as Text;
  }

  String getTempo() {
    final Text tempoTitle = find
        .byKey(PracticeConfigScreen.tempoHeaderKey)
        .evaluate()
        .single
        .widget as Text;
    return tempoTitle.data;
  }

  String getSignal() {
    final Text signalTitle = find
        .byKey(PracticeConfigScreen.signalHeaderKey)
        .evaluate()
        .single
        .widget as Text;
    return signalTitle.data;
  }

  Offset getSliderLeft(WidgetTester tester) {
    final Offset center =
        tester.getCenter(find.byKey(PracticeConfigScreen.drillTimeSliderKey));
    final Offset bottomLeft = tester
        .getBottomLeft(find.byKey(PracticeConfigScreen.drillTimeSliderKey));
    return Offset(bottomLeft.dx, center.dy);
  }

  Offset getSliderRight(WidgetTester tester) {
    final Offset center =
        tester.getCenter(find.byKey(PracticeConfigScreen.drillTimeSliderKey));
    final Offset bottomRight = tester
        .getBottomRight(find.byKey(PracticeConfigScreen.drillTimeSliderKey));
    return Offset(bottomRight.dx, center.dy);
  }

  testWidgets('Renders OK', (WidgetTester tester) async {
    await _render(tester);
    expect(find.text('Up/Down/Middle'), findsOneWidget);
    expect(find.text('Tempo: Random'), findsOneWidget);
    expect(find.text('Drill Time: 10 minutes'), findsOneWidget);
    expect(find.text('Signal: Audio'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('Slider changes drill time', (WidgetTester tester) async {
    await _render(tester);
    expect(getDrillTime().data, equals('Drill Time: 10 minutes'));
    await tester.tap(find.text('Drill Time: 10 minutes'));
    await tester.pumpAndSettle();

    final left = getSliderLeft(tester);
    await tester.tapAt(left);
    await tester.pumpAndSettle();
    expect(getDrillTime().data, equals('Drill Time: 5 minutes'));

    final drag = await tester.startGesture(left);
    await drag.moveTo(getSliderRight(tester));
    await tester.pumpAndSettle();
    expect(getDrillTime().data, equals('Drill Time: 60 minutes'));
  });

  testWidgets('Tempo changes', (WidgetTester tester) async {
    await _render(tester);

    expect(getTempo(), equals('Tempo: Random'));

    await tester.tap(find.text('Tempo: Random'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Slow'));
    await tester.pumpAndSettle();
    expect(getTempo(), equals('Tempo: Slow'));

    await tester.tap(find.text('Fast'));
    await tester.pumpAndSettle();
    expect(getTempo(), equals('Tempo: Fast'));

    await tester.tap(find.text('Random'));
    await tester.pumpAndSettle();
    expect(getTempo(), equals('Tempo: Random'));
  });

  testWidgets('Signal changes', (WidgetTester tester) async {
    await _render(tester);
    expect(getSignal(), equals('Signal: Audio'));
    await tester.tap(find.text('Signal: Audio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Audio and Flash'));
    await tester.pumpAndSettle();
    expect(getSignal(), equals('Signal: Audio and Flash'));
  });
}
