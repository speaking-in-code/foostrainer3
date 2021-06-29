import 'package:flutter_test/flutter_test.dart';
import 'package:ft3/main.dart';
import 'package:ft3/results_db.dart';
import 'package:ft3/static_drills.dart';

void main() {
  group('home screen tests', () {
    late MainApp mainApp;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final db = $FloorResultsDatabase.inMemoryDatabaseBuilder().build();
      final drills = StaticDrills.load();
      mainApp = MainApp(await db, await drills);
    });

    testWidgets('renders nav bar', (WidgetTester tester) async {
      await tester.pumpWidget(mainApp);
      expect(find.text('Practice'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Start Practice'), findsOneWidget);
      expect(find.text('FoosTrainer'), findsOneWidget);
    });
  });
}
