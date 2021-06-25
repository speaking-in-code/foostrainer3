import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ft3/main.dart';
import 'package:ft3/results_db.dart';
import 'package:ft3/static_drills.dart';

// Note: can't test the expansion panels here, because flutter test thinks they
// are open all the time. =(
void main() {
  group('drill chooser screen tests', () {
    MainApp mainApp;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final db = $FloorResultsDatabase.inMemoryDatabaseBuilder().build();
      final drills = StaticDrills.load();
      mainApp = MainApp(await db, await drills);
    });

    testWidgets('renders categories', (WidgetTester tester) async {
      await tester.pumpWidget(mainApp);
      await tester.tap(find.text('Start Practice'));
      await tester.pumpAndSettle();
      expect(find.text('Choose Drill'), findsOneWidget);
      expect(find.text('Stick Pass'), findsOneWidget);
      expect(find.text('Brush Pass'), findsOneWidget);
      expect(find.text('Rollover'), findsOneWidget);
    });

    testWidgets('renders drills', (WidgetTester tester) async {
      await tester.pumpWidget(mainApp);
      await tester.tap(find.text('Start Practice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();
      expect(find.text('Up/Middle'), findsOneWidget);
    });
  });
}
