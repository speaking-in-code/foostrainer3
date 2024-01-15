import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:ft3/app_rater.dart';
import 'package:ft3/firebase_options.dart';
import 'package:ft3/main.dart' as app;
import 'package:ft3/practice_background.dart';
import 'package:ft3/results_db.dart';
import 'package:ft3/results_entities.dart';
import 'package:ft3/static_drills.dart';

Future<void> startFoosTrainer(WidgetTester tester) async {
  final db = ResultsDatabase.init(storage: DbStorage.IN_MEMORY);
  final mainApp = app.MainApp(
    await db,
    await StaticDrills.load(),
    await AppRater.create(),
    await PracticeBackground.init(),
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform),
    debugShowCheckedModeBanner: false,
  );
  await (await db).addData(
      StoredDrill(
          startSeconds: 1500000000,
          drill: 'Pass:Brush Pass',
          tracking: true,
          elapsedSeconds: 600),
      actionList: [
        ActionSummary('Lane', 5, 3),
        ActionSummary('Wall', 2, 2),
      ]);
  await tester.pumpWidget(mainApp);
  await tester.pumpAndSettle();
}
