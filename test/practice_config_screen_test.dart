import 'package:flutter/material.dart';

/// Tests navigation and rendering of the practice config screen.
import 'package:flutter_test/flutter_test.dart';
import 'package:ft3/drill_data.dart';
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

  Tempo getTempo() {
    final RadioListTile<Tempo> tile = find
        .byKey(PracticeConfigScreen.fastKey)
        .evaluate()
        .single
        .widget as RadioListTile<Tempo>;
    return tile.groupValue;
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
    expect(find.text('Tempo'), findsOneWidget);
    expect(find.text('Random'), findsOneWidget);
    expect(find.text('Slow'), findsOneWidget);
    expect(find.text('Fast'), findsOneWidget);

    expect(find.text('Drill Time'), findsOneWidget);
    expect(find.text('10 minutes'), findsOneWidget);

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('Slider changes drill time', (WidgetTester tester) async {
    await _render(tester);
    expect(find.text('Up/Down/Middle'), findsOneWidget);
    expect(find.text('Tempo'), findsOneWidget);
    expect(find.text('Random'), findsOneWidget);
    expect(find.text('Slow'), findsOneWidget);
    expect(find.text('Fast'), findsOneWidget);

    expect(find.text('Drill Time'), findsOneWidget);
    expect(getDrillTime().data, equals('10 minutes'));

    final left = getSliderLeft(tester);
    await tester.tapAt(left);
    await tester.pumpAndSettle();
    expect(getDrillTime().data, equals('5 minutes'));

    final drag = await tester.startGesture(left);
    await drag.moveTo(getSliderRight(tester));
    await tester.pumpAndSettle();
    expect(getDrillTime().data, equals('60 minutes'));
  });

  testWidgets('Tempo changes', (WidgetTester tester) async {
    await _render(tester);

    expect(getTempo(), equals(Tempo.RANDOM));

    await tester.tap(find.text('Slow'));
    await tester.pumpAndSettle();
    expect(getTempo(), equals(Tempo.SLOW));

    await tester.tap(find.text('Fast'));
    await tester.pumpAndSettle();
    expect(getTempo(), equals(Tempo.FAST));

    await tester.tap(find.text('Random'));
    await tester.pumpAndSettle();
    expect(getTempo(), equals(Tempo.RANDOM));
  });
}
