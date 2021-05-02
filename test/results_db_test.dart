import 'package:flutter_test/flutter_test.dart';
import 'package:ft3/results_db.dart';
import 'package:ft3/results_entities.dart';

void main() {
  group('database tests', () {
    const START_SECONDS = 1500000000;
    ResultsDatabase db;
    DrillsDao drills;
    ActionsDao actions;
    SummariesDao summaries;

    setUp(() async {
      db = await $FloorResultsDatabase.inMemoryDatabaseBuilder().build();
      drills = db.drillsDao;
      actions = db.actionsDao;
      summaries = db.summariesDao;
    });

    tearDown(() async {
      await db.close();
    });

    Future<List<WeeklyDrillSummary>> _summary(
        {String drill, String action}) async {
      const MAX_WEEKS = 4;
      return summaries.loadWeeklyDrills(
          numWeeks: MAX_WEEKS, offset: 0, drill: drill, action: action);
    }

    test('summarizes empty table', () async {
      final noDrills = await _summary();
      expect(noDrills, isEmpty);
    });

    test('summarizes drills with no reps', () async {
      await db.addData(StoredDrill(
          startSeconds: START_SECONDS,
          drill: 'Lane Pass',
          tracking: true,
          elapsedSeconds: 60));
      final oneDrill = await _summary();
      expect(
          oneDrill,
          equals([
            WeeklyDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 60, 0, null)
          ]));
    });

    test('summary weeks start on Mondays', () async {
      await db.addData(StoredDrill(
          startSeconds: START_SECONDS,
          drill: 'Lane Pass',
          tracking: true,
          elapsedSeconds: 60));
      final summary = await _summary();
      expect(
          summary,
          equals([
            WeeklyDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 60, 0, null)
          ]));
      expect(summary[0].startDay.weekday, equals(DateTime.monday));
      expect(summary[0].endDay.weekday, equals(DateTime.sunday));
    });

    test('summary groups by weeks', () async {
      await db.addData(StoredDrill(
          startSeconds: START_SECONDS,
          drill: 'Lane Pass',
          tracking: true,
          elapsedSeconds: 60));
      await db.addData(StoredDrill(
          startSeconds: START_SECONDS + 7 * 24 * 3600,
          drill: 'Lane Pass',
          tracking: true,
          elapsedSeconds: 300));
      final weeks = await _summary();
      expect(
          weeks,
          equals([
            WeeklyDrillSummary(
                DateTime(2017, 7, 17), DateTime(2017, 7, 23), 300, 0, null),
            WeeklyDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 60, 0, null),
          ]));
    });

    test('summary no reps', () async {
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Brush Pass',
              tracking: true,
              elapsedSeconds: 60),
          actionList: []);
      final weeks = await _summary();
      expect(
          weeks,
          equals([
            WeeklyDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 60, 0, null),
          ]));
    });

    test('summary adds reps and accuracy', () async {
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Brush Pass',
              tracking: true,
              elapsedSeconds: 60),
          actionList: [
            ActionSummary('Lane', 150, 100),
            ActionSummary('Wall', 100, 20),
          ]);
      final weeks = await _summary();
      expect(
          weeks,
          equals([
            WeeklyDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 60, 250, 0.48),
          ]));
    });

    test('summary no tracking', () async {
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Brush Pass',
              tracking: false,
              elapsedSeconds: 60),
          actionList: [
            ActionSummary('Lane', 150, null),
            ActionSummary('Wall', 100, null),
          ]);
      final weeks = await _summary();
      expect(
          weeks,
          equals([
            WeeklyDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 60, 250, null),
          ]));
    });

    test('summary mixes tracked and untracked', () async {
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Brush Pass',
              tracking: true,
              elapsedSeconds: 1200),
          actionList: [
            ActionSummary('Lane', 150, 75),
            ActionSummary('Wall', 100, 50),
          ]);
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Brush Pass',
              tracking: false,
              elapsedSeconds: 600),
          actionList: [
            ActionSummary('Lane', 50, null),
            ActionSummary('Wall', 50, null),
          ]);
      final weeks = await _summary();
      expect(
          weeks,
          equals([
            WeeklyDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 1800, 350, 0.5),
          ]));
    });

    test('summary limits weeks displayed', () async {
      const ONE_WEEK = 7 * 24 * 3600;
      for (int i = 0; i < 10; ++i) {
        await db.addData(
            StoredDrill(
                startSeconds: START_SECONDS + i * ONE_WEEK,
                drill: 'Brush Pass',
                tracking: true,
                elapsedSeconds: 1200),
            actionList: [
              ActionSummary('Lane', 150, 0),
              ActionSummary('Wall', 100, 0),
            ]);
      }
      final weeks = await _summary();
      expect(
          weeks,
          equals([
            WeeklyDrillSummary(
                DateTime(2017, 9, 11), DateTime(2017, 9, 17), 1200, 250, 0.0),
            WeeklyDrillSummary(
                DateTime(2017, 9, 4), DateTime(2017, 9, 10), 1200, 250, 0.0),
            WeeklyDrillSummary(
                DateTime(2017, 8, 28), DateTime(2017, 9, 3), 1200, 250, 0.0),
            WeeklyDrillSummary(
                DateTime(2017, 8, 21), DateTime(2017, 8, 27), 1200, 250, 0.0),
          ]));
    });

    test('summary filters by drill', () async {
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Brush Pass',
              tracking: true,
              elapsedSeconds: 1200),
          actionList: [
            ActionSummary('Lane', 50, 30),
            ActionSummary('Wall', 50, 30),
          ]);
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Stick Pass',
              tracking: false,
              elapsedSeconds: 600),
          actionList: [
            ActionSummary('Lane', 50, 40),
            ActionSummary('Wall', 50, 40),
          ]);
      var weeks = await _summary(drill: 'Stick Pass');
      expect(
          weeks,
          equals([
            WeeklyDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 600, 100, null),
          ]));
      weeks = await _summary(drill: 'Brush Pass');
      expect(
          weeks,
          equals([
            WeeklyDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 1200, 100, 0.6),
          ]));
    });

    test('summary filters by action', () async {
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Wall & Bounce Pass',
              tracking: true,
              elapsedSeconds: 1200),
          actionList: [
            ActionSummary('Bounce', 50, 30),
            ActionSummary('Wall', 50, 30),
          ]);
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Stick Pass',
              tracking: true,
              elapsedSeconds: 600),
          actionList: [
            ActionSummary('Lane', 50, 40),
            ActionSummary('Wall', 50, 40),
          ]);
      var weeks = await _summary(action: 'Lane');
      expect(
          weeks,
          equals([
            WeeklyDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), null, 50, 0.8),
          ]));
      weeks = await _summary(action: 'Wall');
      expect(
          weeks,
          equals([
            WeeklyDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), null, 100, 0.7),
          ]));
    });

    test('start drill', () async {
      final id = await drills
          .insertDrill(StoredDrill.newDrill(drill: 'Drill', tracking: false));
      final results = await drills.loadDrill(id);
      expect(results.drill, equals('Drill'));
      expect(results.startSeconds, greaterThan(0));
      expect(results.tracking, equals(false));
      expect(results.elapsedSeconds, equals(0));

      final summary = await summaries.loadDrill(db, id);
      expect(summary.drill.drill, equals('Drill'));
      expect(summary.drill.elapsedSeconds, equals(0));
      expect(summary.good, equals(null));
      expect(summary.accuracy, equals(null));
      expect(summary.reps, equals(0));
      expect(summary.actionReps, isEmpty);
    });

    test('add action no accuracy', () async {
      final drillId = await drills
          .insertDrill(StoredDrill.newDrill(drill: 'Passing', tracking: false));
      await actions.incrementAction(drillId, 'Lane', null);
      StoredAction lane = await actions.loadAction(drillId, 'Lane');
      expect(lane.action, equals('Lane'));
      expect(lane.reps, equals(1));
      expect(lane.good, equals(null));

      await actions.incrementAction(drillId, 'Lane', null);
      await actions.incrementAction(drillId, 'Lane', null);
      await actions.incrementAction(drillId, 'Lane', null);
      lane = await actions.loadAction(drillId, 'Lane');
      expect(lane.action, equals('Lane'));
      expect(lane.reps, equals(4));
      expect(lane.good, equals(null));

      final summary = await summaries.loadDrill(db, drillId);
      expect(summary.drill.drill, equals('Passing'));
      expect(summary.drill.elapsedSeconds, equals(0));
      expect(summary.good, equals(null));
      expect(summary.accuracy, equals(null));
      expect(summary.reps, equals(4));
      // This is annoying to write because of
      // https://github.com/dart-lang/sdk/issues/32559.
      expect(summary.actionReps.entries.length, equals(1));
      expect(summary.actionReps, containsPair('Lane', 4));
    });

    test('add action with accuracy', () async {
      final drillId = await drills
          .insertDrill(StoredDrill.newDrill(drill: 'Passing', tracking: true));
      await actions.incrementAction(drillId, 'Lane', false);
      StoredAction lane = await actions.loadAction(drillId, 'Lane');
      expect(lane.action, equals('Lane'));
      expect(lane.reps, equals(1));
      expect(lane.good, equals(0));

      await actions.incrementAction(drillId, 'Lane', true);
      await actions.incrementAction(drillId, 'Lane', true);
      await actions.incrementAction(drillId, 'Lane', true);
      lane = await actions.loadAction(drillId, 'Lane');
      expect(lane.action, equals('Lane'));
      expect(lane.reps, equals(4));
      expect(lane.good, equals(3));

      final summary = await summaries.loadDrill(db, drillId);
      expect(summary.drill.drill, equals('Passing'));
      expect(summary.drill.elapsedSeconds, equals(0));
      expect(summary.good, equals(3));
      expect(summary.accuracy, equals(0.75));
      expect(summary.reps, equals(4));
    });

    Future<void> _insertDrill(DateTime start, int drillCount) async {
      DateTime drillStart = start.add(Duration(days: drillCount));
      final drill = StoredDrill(
          startSeconds: drillStart.millisecondsSinceEpoch ~/ 1000,
          drill: 'Drill $drillCount',
          tracking: false);
      final drillId = await drills.insertDrill(drill);
      for (int action = 0; action < 50; ++action) {
        await actions.incrementAction(drillId, 'Lane', false);
      }
    }

    test('pagination of summaries', () async {
      List<Future<void>> drills = [];
      final start = DateTime.now();
      for (int i = 0; i < 95; ++i) {
        drills.add(_insertDrill(start, i));
      }
      await Future.wait(drills);
      List<DrillSummary> pageOne = await summaries.loadRecentDrills(db, 10, 0);
      expect(pageOne.length, equals(10));
      for (int i = 94, j = 0; i >= 85; --i, ++j) {
        expect(pageOne[j].drill.drill, equals('Drill $i'));
      }
      List<DrillSummary> lastPage =
          await summaries.loadRecentDrills(db, 10, 90);
      expect(lastPage.length, equals(5));
      for (int i = 4, j = 0; i >= 0; --i, ++j) {
        expect(lastPage[j].drill.drill, equals('Drill $i'));
      }
      List<DrillSummary> offPage = await summaries.loadRecentDrills(db, 10, 95);
      expect(offPage.length, equals(0));
    });

    test('delete all works', () async {
      final drillId = await drills
          .insertDrill(StoredDrill.newDrill(drill: 'Passing', tracking: true));
      await actions.incrementAction(drillId, 'Lane', false);
      final found = await drills.loadDrill(drillId);
      expect(found, isNotNull);
      await db.deleteAll();
      final gone = await drills.loadDrill(drillId);
      expect(gone, isNull);
      List<DrillSummary> summary = await summaries.loadRecentDrills(db, 10, 0);
      expect(summary, isEmpty);
    });
  });
}
