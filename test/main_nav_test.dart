/// Tests navigation and rendering of all screens in the app.
/// Does not test the actual practice execution.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:ft3/main.dart';
import 'package:ft3/practice_screen.dart';

void main() {
  Future<void> _render(WidgetTester tester) async {
    MainApp mainApp = MainApp();
    await tester.pumpWidget(mainApp);
    await tester.pump();
  }

  testWidgets('Renders drill types', (WidgetTester tester) async {
    await _render(tester);
    expect(find.text('Drill Type'), findsOneWidget);
    expect(find.text('Push'), findsOneWidget);
    expect(find.text('Rollover'), findsOneWidget);
  });

  testWidgets('Navigates to drill list', (WidgetTester tester) async {
    await _render(tester);
    await tester.tap(find.text('Rollover'));
    await tester.pumpAndSettle();
    expect(find.text('Up'), findsOneWidget);
    expect(find.text('Down'), findsOneWidget);
    expect(find.text('Middle'), findsOneWidget);
    expect(find.text('Up/Down'), findsOneWidget);
  });

  testWidgets('Navigates drill list to main screen',
      (WidgetTester tester) async {
    await _render(tester);
    await tester.tap(find.text('Pull'));
    await tester.pumpAndSettle();
    expect(find.text('Straight'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Drill Type'), findsOneWidget);
    expect(find.text('Push'), findsOneWidget);
    expect(find.text('Rollover'), findsOneWidget);
  });

  testWidgets('Navigates drill list to practice screen',
      (WidgetTester tester) async {
    await _render(tester);
    await tester.tap(find.text('Rollover'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Up'));
    await tester.pumpAndSettle();
    expect(find.text('Up'), findsOneWidget);
    expect(find.text('Reps'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    Text reps =
        find.byKey(PracticeScreen.repsKey).evaluate().single.widget as Text;
    expect(reps.data, equals('0'));

    Text elapsed =
        find.byKey(PracticeScreen.elapsedKey).evaluate().single.widget as Text;
    expect(elapsed.data, equals('00:00:00'));
  });

  testWidgets('Navigates practice back to drill list, back to main',
      (WidgetTester tester) async {
    // Render main app
    await _render(tester);
    // To rollover drills
    await tester.tap(find.text('Rollover'));
    await tester.pumpAndSettle();
    // To Up practice screen
    await tester.tap(find.text('Up'));
    await tester.pumpAndSettle();
    expect(find.text('Up'), findsOneWidget);
    expect(find.text('Reps'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);

    // Back to rollover drills
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rollover'));
    await tester.pumpAndSettle();
    expect(find.text('Up'), findsOneWidget);
    expect(find.text('Down'), findsOneWidget);
    expect(find.text('Middle'), findsOneWidget);

    // Back to drill types/main screen
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Drill Type'), findsOneWidget);
    expect(find.text('Push'), findsOneWidget);
    expect(find.text('Rollover'), findsOneWidget);
  });
}
