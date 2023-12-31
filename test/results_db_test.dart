import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ft3/results_db.dart';
import 'package:ft3/results_entities.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

void main() {
  group('database tests', () {
    const START_SECONDS = 1500000000;
    late ResultsDatabase db;
    late DrillsDao drills;
    late ActionsDao actions;
    late SummariesDao summaries;

    setUp(() async {
      db = await $FloorResultsDatabase.inMemoryDatabaseBuilder().build();
      drills = db.drillsDao;
      actions = db.actionsDao;
      summaries = db.summariesDao;
    });

    tearDown(() async {
      await db.close();
    });

    Future<List<AggregatedDrillSummary>> _summary(AggregationLevel aggLevel,
        {required int limit, String? drill, String? action}) async {
      return summaries.loadAggregateDrills(
          aggLevel: aggLevel,
          limit: limit,
          offset: 0,
          drill: drill,
          action: action);
    }

    test('inserts and removes drills', () async {
      int drillId = await drills.insertDrill(StoredDrill(
          startSeconds: 5,
          drill: 'Pass:Something',
          tracking: false,
          elapsedSeconds: 60));
      StoredDrill? loaded = await drills.loadDrill(drillId);
      expect(loaded!.drill, equals('Pass:Something'));

      await drills.removeDrill(drillId);
      loaded = await drills.loadDrill(drillId);
      expect(loaded, isNull);
    });

    test('inserts actions', () async {
      const DRILL_ID = 100;
      await drills.insertDrill(StoredDrill(
          id: DRILL_ID,
          startSeconds: 5,
          drill: 'Pass:Something',
          tracking: false,
          elapsedSeconds: 60));
      await actions.insertAction(StoredAction(
          id: null, drillId: DRILL_ID, action: 'Lane', reps: 5, good: 4));
      StoredAction? found = await actions.loadAction(DRILL_ID, 'Lane');
      expect(found!.good, equals(4));
    });

    test('loads actions', () async {
      const DRILL_ID = 100;
      await drills.insertDrill(StoredDrill(
          id: DRILL_ID,
          startSeconds: 5,
          drill: 'Pass:Something',
          tracking: false,
          elapsedSeconds: 60));
      await actions.insertAction(StoredAction(
          id: null, drillId: DRILL_ID, action: 'Lane', reps: 30, good: 4));
      await actions.insertAction(StoredAction(
          id: null, drillId: DRILL_ID, action: 'Wall', reps: 5, good: 4));
      List<StoredAction> found = await actions.loadActions(DRILL_ID);
      expect(found.length, equals(2));
      expect(found[0].action, equals('Lane'));
      expect(found[0].reps, equals(30));
      expect(found[1].action, equals('Wall'));
      expect(found[1].reps, equals(5));
    });

    test('summarizes empty table', () async {
      var noDrills = await _summary(AggregationLevel.WEEKLY, limit: 10);
      expect(noDrills, isEmpty);
      noDrills = await _summary(AggregationLevel.DAILY, limit: 10);
      expect(noDrills, isEmpty);
      noDrills = await _summary(AggregationLevel.MONTHLY, limit: 10);
      expect(noDrills, isEmpty);
    });

    test('summarizes drills with no reps', () async {
      await db.addData(StoredDrill(
          startSeconds: START_SECONDS,
          drill: 'Pass:Lane Pass',
          tracking: true,
          elapsedSeconds: 60));
      final oneDrill = await _summary(AggregationLevel.WEEKLY, limit: 10);
      expect(
          oneDrill,
          equals([
            AggregatedDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 60, 0, null)
          ]));
    });

    test('summary weeks start on Mondays', () async {
      await db.addData(StoredDrill(
          startSeconds: START_SECONDS,
          drill: 'Pass:Lane Pass',
          tracking: true,
          elapsedSeconds: 60));
      final summary = await _summary(AggregationLevel.WEEKLY, limit: 10);
      expect(
          summary,
          equals([
            AggregatedDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 60, 0, null)
          ]));
      expect(summary[0].startDay.weekday, equals(DateTime.monday));
      final endDay = summary[0].endDay.subtract(Duration(seconds: 1));
      expect(endDay.weekday, equals(DateTime.sunday));
    });

    test('summary groups by weeks', () async {
      await db.addData(StoredDrill(
          startSeconds: START_SECONDS,
          drill: 'Pass:Lane Pass',
          tracking: true,
          elapsedSeconds: 60));
      await db.addData(StoredDrill(
          startSeconds: START_SECONDS + 7 * 24 * 3600,
          drill: 'Pass:Lane Pass',
          tracking: true,
          elapsedSeconds: 300));
      final weeks = await _summary(AggregationLevel.WEEKLY, limit: 10);
      expect(
          weeks,
          equals([
            AggregatedDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 60, 0, null),
            AggregatedDrillSummary(
                DateTime(2017, 7, 17), DateTime(2017, 7, 23), 300, 0, null),
          ]));
    });

    test('summary groups by days', () async {
      int currentSeconds = START_SECONDS;
      for (int i = 0; i < 10; ++i) {
        await db.addData(StoredDrill(
            startSeconds: currentSeconds,
            drill: 'Pass:Lane Pass',
            tracking: true,
            elapsedSeconds: 60));
        currentSeconds += 24 * 3600;
      }
      final weeks = await _summary(AggregationLevel.DAILY, limit: 5);
      expect(
          weeks,
          equals([
            AggregatedDrillSummary(
                DateTime(2017, 7, 18), DateTime(2017, 7, 19), 60, 0, null),
            AggregatedDrillSummary(
                DateTime(2017, 7, 19), DateTime(2017, 7, 20), 60, 0, null),
            AggregatedDrillSummary(
                DateTime(2017, 7, 20), DateTime(2017, 7, 21), 60, 0, null),
            AggregatedDrillSummary(
                DateTime(2017, 7, 21), DateTime(2017, 7, 22), 60, 0, null),
            AggregatedDrillSummary(
                DateTime(2017, 7, 22), DateTime(2017, 7, 23), 60, 0, null),
          ]));
    });

    test('summary groups by months', () async {
      int currentSeconds = START_SECONDS;
      for (int i = 0; i < 10; ++i) {
        await db.addData(StoredDrill(
            startSeconds: currentSeconds,
            drill: 'Pass:Lane Pass',
            tracking: true,
            elapsedSeconds: 60));
        currentSeconds += 30 * 24 * 3600;
      }
      final weeks = await _summary(AggregationLevel.MONTHLY, limit: 5);
      expect(
          weeks,
          equals([
            AggregatedDrillSummary(
                DateTime(2017, 12, 1), DateTime(2018, 1, 1), 60, 0, null),
            AggregatedDrillSummary(
                DateTime(2018, 1, 1), DateTime(2018, 2, 1), 60, 0, null),
            AggregatedDrillSummary(
                DateTime(2018, 2, 1), DateTime(2018, 3, 1), 60, 0, null),
            AggregatedDrillSummary(
                DateTime(2018, 3, 1), DateTime(2018, 4, 1), 60, 0, null),
            AggregatedDrillSummary(
                DateTime(2018, 4, 1), DateTime(2018, 5, 1), 60, 0, null),
          ]));
    });

    final _random = Random();

    Future<void> _tryDate(int secsSinceEpoch) async {
      await db.deleteAll();
      final date = DateTime.fromMillisecondsSinceEpoch(secsSinceEpoch * 1000);
      final drillId = await drills.insertDrill(StoredDrill(
          drill: 'Pass:Passing',
          tracking: false,
          startSeconds: secsSinceEpoch,
          elapsedSeconds: 60));
      await actions.incrementAction(drillId, 'Lane', ActionUpdate.MISSED);

      List<AggregatedDrillSummary> summaryList =
          await summaries.loadAggregateDrills(
              aggLevel: AggregationLevel.WEEKLY, limit: 10, offset: 0);
      expect(summaryList.length, equals(1));
      AggregatedDrillSummary weekly = summaryList.first;
      List<DrillSummary> found = await summaries.loadDrillsByDate(db,
          limit: 100, offset: 0, start: weekly.startDay, end: weekly.endDay);
      expect(found.length, equals(1),
          reason:
              'Bad time $date, $secsSinceEpoch, should be in range ${weekly.startDay} - ${weekly.endDay}');
      expect(found[0].drill.drill, equals('Pass:Passing'));
    }

    test('2021 fall time change', () async {
      await _tryDate(1636356073);
    });

    test('2021 spring time change', () async {
      await _tryDate(
          DateTime(2021, 3, 14, 12, 0, 0).millisecondsSinceEpoch ~/ 1000);
    });

    test('summary and drill load dates align', () async {
      for (int i = 0; i < 100; ++i) {
        final randomSeconds =
            START_SECONDS + _random.nextInt(10 * 365 * 24 * 3600);
        await _tryDate(randomSeconds);
      }
    });

    // Test out a case where we straddle a week boundary in UTC vs PDT.
    // This is Monday May 3 UTC, but Sunday May 2 PDT.
    test('tricky date', () async {
      await _tryDate(1620001414);
    });

    test('summary no reps', () async {
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Pass:Brush Pass',
              tracking: true,
              elapsedSeconds: 60),
          actionList: []);
      final weeks = await _summary(AggregationLevel.WEEKLY, limit: 10);
      expect(
          weeks,
          equals([
            AggregatedDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 60, 0, null),
          ]));
    });

    test('summary adds reps and accuracy', () async {
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Pass:Brush Pass',
              tracking: true,
              elapsedSeconds: 60),
          actionList: [
            ActionSummary('Lane', 150, 100),
            ActionSummary('Wall', 100, 20),
          ]);
      final weeks = await _summary(AggregationLevel.WEEKLY, limit: 10);
      expect(
          weeks,
          equals([
            AggregatedDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 60, 250, 0.48),
          ]));
    });

    test('repeat entry for same drill', () async {
      final drillId = await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Pass:Brush Pass',
              tracking: true,
              elapsedSeconds: 60),
          actionList: [
            ActionSummary('Lane', 5, 3),
            ActionSummary('Wall', 2, 2),
          ]);
      StoredDrill? same = await (db.drillsDao.loadDrill(drillId));
      final repeated = await db.drillsDao.insertDrill(same!);
      expect(repeated, equals(drillId));
    });

    test('removes drill', () async {
      final drillId = await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Pass:Brush Pass',
              tracking: true,
              elapsedSeconds: 60),
          actionList: [
            ActionSummary('Lane', 5, 3),
          ]);
      StoredDrill? found = await (db.drillsDao.loadDrill(drillId));
      expect(found!.drill, equals('Pass:Brush Pass'));
      await db.drillsDao.removeDrill(drillId);
      found = await (db.drillsDao.loadDrill(drillId));
      expect(found, isNull);
    });

    test('removes drill with no actions', () async {
      final drillId = await db.addData(
        StoredDrill(
            startSeconds: START_SECONDS,
            drill: 'Pass:Brush Pass',
            tracking: true,
            elapsedSeconds: 60),
      );
      StoredDrill? found = await (db.drillsDao.loadDrill(drillId));
      expect(found!.drill, equals('Pass:Brush Pass'));
      await db.drillsDao.removeDrill(drillId);
      found = await (db.drillsDao.loadDrill(drillId));
      expect(found, isNull);
    });

    test('Handles removing non-existent drill', () async {
      final drillId = await db.addData(
        StoredDrill(
            startSeconds: START_SECONDS,
            drill: 'Pass:Brush Pass',
            tracking: true,
            elapsedSeconds: 60),
      );
      StoredDrill? found = await (db.drillsDao.loadDrill(drillId));
      expect(found!.drill, equals('Pass:Brush Pass'));
      await db.drillsDao.removeDrill(drillId + 1);
      found = await (db.drillsDao.loadDrill(drillId));
      expect(found!.drill, equals('Pass:Brush Pass'));
    });

    test('summary no tracking', () async {
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Pass:Brush Pass',
              tracking: false,
              elapsedSeconds: 60),
          actionList: [
            ActionSummary('Lane', 150, null),
            ActionSummary('Wall', 100, null),
          ]);
      final weeks = await _summary(AggregationLevel.WEEKLY, limit: 10);
      expect(
          weeks,
          equals([
            AggregatedDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 60, 250, null),
          ]));
    });

    test('summary mixes tracked and untracked', () async {
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Pass:Brush Pass',
              tracking: true,
              elapsedSeconds: 1200),
          actionList: [
            ActionSummary('Lane', 150, 75),
            ActionSummary('Wall', 100, 50),
          ]);
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Pass:Brush Pass',
              tracking: false,
              elapsedSeconds: 600),
          actionList: [
            ActionSummary('Lane', 50, null),
            ActionSummary('Wall', 50, null),
          ]);
      final weeks = await _summary(AggregationLevel.WEEKLY, limit: 10);
      expect(
          weeks,
          equals([
            AggregatedDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 1800, 350, 0.5),
          ]));
    });

    test('summary limits weeks displayed', () async {
      const ONE_WEEK = 7 * 24 * 3600;
      for (int i = 0; i < 10; ++i) {
        await db.addData(
            StoredDrill(
                startSeconds: START_SECONDS + i * ONE_WEEK,
                drill: 'Pass:Brush Pass',
                tracking: true,
                elapsedSeconds: 1200),
            actionList: [
              ActionSummary('Lane', 150, 0),
              ActionSummary('Wall', 100, 0),
            ]);
      }
      final weeks = await _summary(AggregationLevel.WEEKLY, limit: 4);
      expect(
          weeks,
          equals([
            AggregatedDrillSummary(
                DateTime(2017, 8, 21), DateTime(2017, 8, 27), 1200, 250, 0.0),
            AggregatedDrillSummary(
                DateTime(2017, 8, 28), DateTime(2017, 9, 3), 1200, 250, 0.0),
            AggregatedDrillSummary(
                DateTime(2017, 9, 4), DateTime(2017, 9, 10), 1200, 250, 0.0),
            AggregatedDrillSummary(
                DateTime(2017, 9, 11), DateTime(2017, 9, 17), 1200, 250, 0.0),
          ]));
    });

    test('summary filters by drill', () async {
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Pass:Brush Pass',
              tracking: true,
              elapsedSeconds: 1200),
          actionList: [
            ActionSummary('Lane', 50, 30),
            ActionSummary('Wall', 50, 30),
          ]);
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Pass:Stick Pass',
              tracking: false,
              elapsedSeconds: 600),
          actionList: [
            ActionSummary('Lane', 50, 40),
            ActionSummary('Wall', 50, 40),
          ]);
      var weeks = await _summary(AggregationLevel.WEEKLY,
          limit: 10, drill: 'Pass:Stick Pass');
      expect(
          weeks,
          equals([
            AggregatedDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 600, 100, null),
          ]));
      weeks = await _summary(AggregationLevel.WEEKLY,
          limit: 10, drill: 'Pass:Brush Pass');
      expect(
          weeks,
          equals([
            AggregatedDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 1200, 100, 0.6),
          ]));
    });

    test('summary filters by action', () async {
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Pass:Wall & Bounce Pass',
              tracking: true,
              elapsedSeconds: 1200),
          actionList: [
            ActionSummary('Bounce', 50, 30),
            ActionSummary('Wall', 50, 30),
          ]);
      await db.addData(
          StoredDrill(
              startSeconds: START_SECONDS,
              drill: 'Pass:Stick Pass',
              tracking: true,
              elapsedSeconds: 600),
          actionList: [
            ActionSummary('Lane', 50, 40),
            ActionSummary('Wall', 50, 40),
          ]);
      var weeks =
          await _summary(AggregationLevel.WEEKLY, limit: 10, action: 'Lane');
      expect(
          weeks,
          equals([
            AggregatedDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 0, 50, 0.8),
          ]));
      weeks =
          await _summary(AggregationLevel.WEEKLY, limit: 10, action: 'Wall');
      expect(
          weeks,
          equals([
            AggregatedDrillSummary(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 0, 100, 0.7),
          ]));
    });

    test('start drill', () async {
      final id = await drills.insertDrill(
          StoredDrill.newDrill(drill: 'Shot:Drill', tracking: false));
      final results = await (drills.loadDrill(id));
      expect(results!.drill, equals('Shot:Drill'));
      expect(results.startSeconds, greaterThan(0));
      expect(results.tracking, equals(false));
      expect(results.elapsedSeconds, equals(0));

      DrillSummary? summary = await summaries.loadDrill(db, id);
      expect(summary!.drill.drill, equals('Shot:Drill'));
      expect(summary.drill.elapsedSeconds, equals(0));
      expect(summary.good, equals(null));
      expect(summary.accuracy, equals(null));
      expect(summary.reps, equals(0));
      expect(summary.actions, isEmpty);
    });

    test('add action no accuracy', () async {
      final drillId = await drills.insertDrill(
          StoredDrill.newDrill(drill: 'Pass:Passing', tracking: false));
      await actions.incrementAction(drillId, 'Lane', ActionUpdate.NONE);
      StoredAction? lane = await (actions.loadAction(drillId, 'Lane'));
      expect(lane!.action, equals('Lane'));
      expect(lane.reps, equals(1));
      expect(lane.good, equals(null));

      await actions.incrementAction(drillId, 'Lane', ActionUpdate.NONE);
      await actions.incrementAction(drillId, 'Lane', ActionUpdate.NONE);
      await actions.incrementAction(drillId, 'Lane', ActionUpdate.NONE);
      lane = await (actions.loadAction(drillId, 'Lane'));
      expect(lane!.action, equals('Lane'));
      expect(lane.reps, equals(4));
      expect(lane.good, equals(null));

      final summary = await summaries.loadDrill(db, drillId);
      expect(summary!.drill.drill, equals('Pass:Passing'));
      expect(summary.drill.elapsedSeconds, equals(0));
      expect(summary.good, equals(null));
      expect(summary.accuracy, equals(null));
      expect(summary.reps, equals(4));
      // This is annoying to write because of
      // https://github.com/dart-lang/sdk/issues/32559.
      expect(summary.actions.entries.length, equals(1));
      final action = summary.actions['Lane']!;
      expect(action.reps, equals(4));
      expect(action.good, equals(null));
      expect(action.action, equals('Lane'));
    });

    test('add action with accuracy', () async {
      final drillId = await drills.insertDrill(
          StoredDrill.newDrill(drill: 'Pass:Passing', tracking: true));
      await actions.incrementAction(drillId, 'Lane', ActionUpdate.MISSED);
      StoredAction? lane = await (actions.loadAction(drillId, 'Lane'));
      expect(lane!.action, equals('Lane'));
      expect(lane.reps, equals(1));
      expect(lane.good, equals(0));

      await actions.incrementAction(drillId, 'Lane', ActionUpdate.GOOD);
      await actions.incrementAction(drillId, 'Lane', ActionUpdate.GOOD);
      await actions.incrementAction(drillId, 'Lane', ActionUpdate.GOOD);
      lane = await (actions.loadAction(drillId, 'Lane'));
      expect(lane!.action, equals('Lane'));
      expect(lane.reps, equals(4));
      expect(lane.good, equals(3));

      final summary = await summaries.loadDrill(db, drillId);
      expect(summary!.drill.drill, equals('Pass:Passing'));
      expect(summary.drill.elapsedSeconds, equals(0));
      expect(summary.good, equals(3));
      expect(summary.accuracy, equals(0.75));
      expect(summary.reps, equals(4));
    });

    Future<void> _insertDrill(DateTime start, int drillCount) async {
      DateTime drillStart = start.add(Duration(days: drillCount));
      final drill = StoredDrill(
          startSeconds: drillStart.millisecondsSinceEpoch ~/ 1000,
          drill: 'Shot:Drill $drillCount',
          elapsedSeconds: 0,
          tracking: false);
      final drillId = await drills.insertDrill(drill);
      for (int action = 0; action < 50; ++action) {
        await actions.incrementAction(drillId, 'Lane', ActionUpdate.MISSED);
      }
    }

    test('pagination of summaries', () async {
      List<Future<void>> drills = [];
      final start = DateTime.now();
      for (int i = 0; i < 95; ++i) {
        drills.add(_insertDrill(start, i));
      }
      await Future.wait(drills);
      List<DrillSummary> pageOne =
          await summaries.loadDrillsByDate(db, limit: 10, offset: 0);
      expect(pageOne.length, equals(10));
      for (int i = 94, j = 0; i >= 85; --i, ++j) {
        expect(pageOne[j].drill.drill, equals('Shot:Drill $i'));
      }
      List<DrillSummary> lastPage =
          await summaries.loadDrillsByDate(db, limit: 10, offset: 90);
      expect(lastPage.length, equals(5));
      for (int i = 4, j = 0; i >= 0; --i, ++j) {
        expect(lastPage[j].drill.drill, equals('Shot:Drill $i'));
      }
      List<DrillSummary> offPage =
          await summaries.loadDrillsByDate(db, limit: 10, offset: 95);
      expect(offPage.length, equals(0));
    });

    test('delete all works', () async {
      final drillId = await drills.insertDrill(
          StoredDrill.newDrill(drill: 'Pass:Passing', tracking: true));
      await actions.incrementAction(drillId, 'Lane', ActionUpdate.MISSED);
      final found = await drills.loadDrill(drillId);
      expect(found, isNotNull);
      await db.deleteAll();
      final gone = await drills.loadDrill(drillId);
      expect(gone, isNull);
      List<DrillSummary> summary =
          await summaries.loadDrillsByDate(db, limit: 10, offset: 0);
      expect(summary, isEmpty);
    });

    int? _secondsSinceEpoch(DateTime? when) =>
        when != null ? when.millisecondsSinceEpoch ~/ 1000 : null;

    test('date range works', () async {
      final empty = await (drills.dateRange());
      expect(empty!.earliest, isNull);
      expect(empty.latest, isNull);

      final now = DateTime.now();
      await drills.insertDrill(StoredDrill(
          drill: 'Pass:Passing',
          tracking: true,
          elapsedSeconds: 0,
          startSeconds: _secondsSinceEpoch(now)!));
      final single = await (drills.dateRange());
      expect(_secondsSinceEpoch(single!.earliest),
          equals(_secondsSinceEpoch(now)));
      expect(
          _secondsSinceEpoch(single.latest), equals(_secondsSinceEpoch(now)));

      final lastMonth = now.subtract(Duration(days: 45));
      await drills.insertDrill(StoredDrill(
          drill: 'Pass:Passing',
          tracking: true,
          elapsedSeconds: 0,
          startSeconds: _secondsSinceEpoch(lastMonth)!));
      final both = await (drills.dateRange());
      expect(_secondsSinceEpoch(both!.earliest),
          equals(_secondsSinceEpoch(lastMonth)));
      expect(_secondsSinceEpoch(both.latest), equals(_secondsSinceEpoch(now)));

      final manyMonthsAgo = lastMonth.subtract(Duration(days: 90));
      await drills.insertDrill(StoredDrill(
          drill: 'Pass:Passing',
          tracking: true,
          elapsedSeconds: 0,
          startSeconds: _secondsSinceEpoch(manyMonthsAgo)!));
      final all = await (drills.dateRange());
      expect(_secondsSinceEpoch(all!.earliest),
          equals(_secondsSinceEpoch(manyMonthsAgo)));
      expect(_secondsSinceEpoch(both.latest), equals(_secondsSinceEpoch(now)));
    });

    test('action summary with no actions', () async {
      await drills.insertDrill(
          StoredDrill.newDrill(drill: 'Pass:Lane', tracking: true));
      final summary = await summaries.loadWeeklyActionReps('Lane', 10, 0);
      expect(summary, isEmpty);
    });

    test('action summary with one repeated action', () async {
      final drillId = await drills.insertDrill(StoredDrill(
          drill: 'Pass:Lane',
          tracking: true,
          startSeconds: START_SECONDS,
          elapsedSeconds: 60));
      for (int i = 0; i < 10; ++i) {
        await actions.incrementAction(drillId, 'Lane', ActionUpdate.MISSED);
      }
      final summary = await summaries.loadWeeklyActionReps('Pass:Lane', 10, 0);
      expect(
          summary,
          containsAllInOrder([
            AggregatedActionReps('2017-07-10', '2017-07-16', 'Lane', 10, 0),
          ]));
    });

    test('action summary with multiple actions', () async {
      final drillId = await drills.insertDrill(StoredDrill(
          drill: 'Pass:Lane/Wall',
          tracking: true,
          startSeconds: START_SECONDS,
          elapsedSeconds: 60));
      for (int i = 0; i < 10; ++i) {
        await actions.incrementAction(drillId, 'Lane', ActionUpdate.GOOD);
      }
      for (int i = 0; i < 10; ++i) {
        await actions.incrementAction(drillId, 'Wall', ActionUpdate.MISSED);
      }
      final summary =
          await summaries.loadWeeklyActionReps('Pass:Lane/Wall', 10, 0);
      expect(
          summary,
          containsAllInOrder([
            AggregatedActionReps('2017-07-10', '2017-07-16', 'Lane', 10, 1.0),
            AggregatedActionReps('2017-07-10', '2017-07-16', 'Wall', 10, 0),
          ]));
    });

    test('action summary with no tracking', () async {
      final drillId = await drills.insertDrill(StoredDrill(
          drill: 'Pass:Lane/Wall',
          tracking: false,
          startSeconds: START_SECONDS,
          elapsedSeconds: 60));
      for (int i = 0; i < 10; ++i) {
        await actions.incrementAction(drillId, 'Lane', ActionUpdate.GOOD);
      }
      for (int i = 0; i < 10; ++i) {
        await actions.incrementAction(drillId, 'Wall', ActionUpdate.MISSED);
      }
      final summary =
          await summaries.loadWeeklyActionReps('Pass:Lane/Wall', 10, 0);
      expect(
          summary,
          containsAllInOrder([
            AggregatedActionReps('2017-07-10', '2017-07-16', 'Lane', 10, null),
            AggregatedActionReps('2017-07-10', '2017-07-16', 'Wall', 10, null),
          ]));
    });

    test('renames pass to stick pass', () async {
      final id1 = await db.drillsDao.insertDrill(
          StoredDrill.newDrill(drill: 'Pass:Wall', tracking: true));
      final id2 = await db.drillsDao.insertDrill(
          StoredDrill.newDrill(drill: 'Pass:Lane', tracking: false));
      final otherDrill = await db.drillsDao.insertDrill(
          StoredDrill.newDrill(drill: 'Pull:Straight', tracking: false));
      await renameStickPassMigration.migrate(db.database as sqflite.Database);

      final migrated1 = await (db.drillsDao.loadDrill(id1));
      expect(migrated1!.drill, equals('Stick Pass:Wall'));
      expect(migrated1.tracking, isTrue);

      final migrated2 = await (db.drillsDao.loadDrill(id2));
      expect(migrated2!.drill, equals('Stick Pass:Lane'));
      expect(migrated2.tracking, isFalse);

      final unmodified = await (db.drillsDao.loadDrill(otherDrill));
      expect(unmodified!.drill, equals('Pull:Straight'));
      expect(unmodified.tracking, isFalse);
    });
  });
}
