import 'dart:math';

import 'package:flutter_driver/driver_extension.dart';
import 'package:ft3/main.dart' as app;
import 'package:flutter/widgets.dart';

import 'package:ft3/practice_background.dart';
import 'package:ft3/progress_chooser_sheet.dart';
import 'package:ft3/results_db.dart';
import 'package:ft3/results_entities.dart';
import 'package:ft3/screenshot_data.dart';
import 'package:ft3/static_drills.dart';

final _rand = Random(/*seed*/ 0xf005);

int _randBetween(int min, int max) {
  return min + _rand.nextInt(max - min + 1);
}

void main() async {
  // Enable the flutter driver extension so that tests can control the app.
  enableFlutterDriverExtension();
  // Remove the debug logo, so screenshots look better.
  WidgetsApp.debugAllowBannerOverride = false;
  // Set up static data for screenshots.
  final drills = await StaticDrills.load();
  final db = await ResultsDatabase.init();
  await db.deleteAll();
  final rolloverId = await _addRollover(db, drills);
  await _addBrush(db, drills);
  await _initActiveDrill(db, drills, rolloverId);
  await _addPullProgress(db, drills);
  await _addCalendarDays(db, drills);
  ProgressChooserSheet.includeCloseButton = true;
  runApp(app.MainApp(db, drills));
}

Future<int> _addRollover(ResultsDatabase db, StaticDrills drills) async {
  final rollover = drills.getDrill('Rollover:Up/Down/Middle');
  final results = StoredDrill(
    startSeconds:
        DateTime(2020, 6, 13, 8, 45, 0).millisecondsSinceEpoch ~/ 1000,
    drill: rollover.fullName,
    tracking: true,
    elapsedSeconds: 12 * 60 + 45,
  );
  final drillId = await db.drillsDao.insertDrill(results);
  await db.actionsDao.insertAction(
      StoredAction(drillId: drillId, action: 'Up', reps: 12, good: 10));
  await db.actionsDao.insertAction(
      StoredAction(drillId: drillId, action: 'Down', reps: 7, good: 4));
  await db.actionsDao.insertAction(
      StoredAction(drillId: drillId, action: 'Middle', reps: 9, good: 4));
  return drillId;
}

Future<int> _addBrush(ResultsDatabase db, StaticDrills drills) async {
  final brush = drills.getDrill('Brush Pass:Lane/Wall');
  final results = StoredDrill(
    startSeconds:
        DateTime(2020, 6, 12, 15, 12, 0).millisecondsSinceEpoch ~/ 1000,
    drill: brush.fullName,
    tracking: true,
    elapsedSeconds: 10 * 60,
  );
  final drillId = await db.drillsDao.insertDrill(results);
  await db.actionsDao.insertAction(
      StoredAction(drillId: drillId, action: 'Wall', reps: 8, good: 7));
  await db.actionsDao.insertAction(
      StoredAction(drillId: drillId, action: 'Lane', reps: 13, good: 8));
  return drillId;
}

Future<void> _addCalendarDays(ResultsDatabase db, StaticDrills drills) async {
  DateTime date = DateTime(2020, 5, 1, 12, 00, 00);
  for (int i = 0; i < 10; ++i) {
    date = date.add(Duration(days: _randBetween(1, 3)));
    final pass = drills.getDrill('Stick Pass:Wall');
    final results = StoredDrill(
      startSeconds: date.millisecondsSinceEpoch ~/ 1000,
      drill: pass.fullName,
      tracking: false,
      elapsedSeconds: _randBetween(600, 1800),
    );
    final drillId = await db.drillsDao.insertDrill(results);
    final reps = _randBetween(30, 90);
    await db.actionsDao.insertAction(
        StoredAction(drillId: drillId, action: 'Wall', reps: reps));
  }
}

Future<void> _addPullProgress(ResultsDatabase db, StaticDrills drills) async {
  final pull = drills.getDrill('Pull:Straight/Middle/Long');
  DateTime date = DateTime(2020, 5, 1);
  for (int i = 0; i < 8; ++i) {
    date = date.add(Duration(days: _randBetween(5, 7)));
    date = DateTime(date.year, date.month, date.day, _randBetween(12, 18),
        _randBetween(0, 60), 0);
    final results = StoredDrill(
      startSeconds: date.millisecondsSinceEpoch ~/ 1000,
      drill: pull.fullName,
      tracking: true,
      elapsedSeconds: _randBetween(600, 1800),
    );
    final drillId = await db.drillsDao.insertDrill(results);
    final reps = _randBetween(30, 90);
    final minPercentage = i * .1;
    final maxPercentage = 0.8;
    final good = _randBetween(
        (minPercentage * reps).floor(), (maxPercentage * reps).floor());
    await db.actionsDao.insertAction(
        StoredAction(drillId: drillId, action: 'Long', reps: reps, good: good));
  }
  return;
}

// Override the screenshot so that it looks good, and also works around
// https://github.com/flutter/flutter/issues/35521 which sometimes triggers.
Future<void> _initActiveDrill(
    ResultsDatabase db, StaticDrills staticDrills, int drillId) async {
  final summary = await db.summariesDao.loadDrill(db, drillId);
  final drillConfig = staticDrills.getDrill(summary.drill.drill);
  drillConfig.practiceMinutes = 20;
  ScreenshotData.progress = PracticeProgress()
    ..drill = drillConfig
    ..practiceState = PracticeState.playing
    ..action = 'Up'
    ..results = summary;
}
