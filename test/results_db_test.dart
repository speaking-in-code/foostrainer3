import 'package:flutter_test/flutter_test.dart';
import 'package:ft3/results_db.dart';
import 'package:ft3/results_info.dart';

class _Actions {
  final String action;
  final int reps;
  final int goodCount;

  _Actions(this.action, this.reps, this.goodCount);
}

void main() {
  group('database tests', () {
    const START_SECONDS = 1500000000;
    const END_SECONDS = 1600000000;
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

    Future<void> _addResults(ResultsInfo results,
        {List<_Actions> actionList}) async {
      final id = await drills.insertResults(results);
      if (actionList == null) {
        actionList = [];
      }
      for (_Actions action in actionList) {
        for (int i = 0; i < action.reps; ++i) {
          bool isGood;
          if (results.tracking) {
            isGood = (i < action.goodCount);
          }
          await actions.incrementAction(id, action.action, isGood);
        }
      }
    }

    Future<List<WeeklyDrill>> _summary({String drill, String action}) async {
      const MAX_WEEKS = 4;
      return summaries.weeklyDrills(
          endSeconds: END_SECONDS,
          numWeeks: MAX_WEEKS,
          drill: drill,
          action: action);
    }

    test('summarizes empty table', () async {
      final noDrills = await _summary();
      expect(noDrills, isEmpty);
    });

    test('summarizes drills with no reps', () async {
      await _addResults(ResultsInfo(
          startSeconds: START_SECONDS,
          drill: 'Lane Pass',
          tracking: true,
          elapsedSeconds: 60));
      final oneDrill = await _summary();
      expect(
          oneDrill,
          equals([
            WeeklyDrill(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 60, 0, null)
          ]));
    });

    test('summary weeks start on Mondays', () async {
      await _addResults(ResultsInfo(
          startSeconds: START_SECONDS,
          drill: 'Lane Pass',
          tracking: true,
          elapsedSeconds: 60));
      final summary = await _summary();
      expect(
          summary,
          equals([
            WeeklyDrill(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 60, 0, null)
          ]));
      expect(summary[0].startDay.weekday, equals(DateTime.monday));
      expect(summary[0].endDay.weekday, equals(DateTime.sunday));
    });

    test('summary groups by weeks', () async {
      await _addResults(ResultsInfo(
          startSeconds: START_SECONDS,
          drill: 'Lane Pass',
          tracking: true,
          elapsedSeconds: 60));
      await _addResults(ResultsInfo(
          startSeconds: START_SECONDS + 7 * 24 * 3600,
          drill: 'Lane Pass',
          tracking: true,
          elapsedSeconds: 300));
      final weeks = await _summary();
      expect(
          weeks,
          equals([
            WeeklyDrill(
                DateTime(2017, 7, 17), DateTime(2017, 7, 23), 300, 0, null),
            WeeklyDrill(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 60, 0, null),
          ]));
    });

    test('summary adds reps and accuracy', () async {
      await _addResults(
          ResultsInfo(
              startSeconds: START_SECONDS,
              drill: 'Brush Pass',
              tracking: true,
              elapsedSeconds: 60),
          actionList: [
            _Actions('Lane', 150, 100),
            _Actions('Wall', 100, 20),
          ]);
      final weeks = await _summary();
      expect(
          weeks,
          equals([
            WeeklyDrill(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 60, 250, 0.48),
          ]));
    });

    test('summary mixes tracked and untracked', () async {
      await _addResults(
          ResultsInfo(
              startSeconds: START_SECONDS,
              drill: 'Brush Pass',
              tracking: true,
              elapsedSeconds: 1200),
          actionList: [
            _Actions('Lane', 150, 75),
            _Actions('Wall', 100, 50),
          ]);
      await _addResults(
          ResultsInfo(
              startSeconds: START_SECONDS,
              drill: 'Brush Pass',
              tracking: false,
              elapsedSeconds: 600),
          actionList: [
            _Actions('Lane', 50, null),
            _Actions('Wall', 50, null),
          ]);
      final weeks = await _summary();
      expect(
          weeks,
          equals([
            WeeklyDrill(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 1800, 350, 0.5),
          ]));
    });

    test('summary limits weeks displayed', () async {
      const ONE_WEEK = 7 * 24 * 3600;
      for (int i = 0; i < 10; ++i) {
        await _addResults(
            ResultsInfo(
                startSeconds: START_SECONDS + i * ONE_WEEK,
                drill: 'Brush Pass',
                tracking: true,
                elapsedSeconds: 1200),
            actionList: [
              _Actions('Lane', 150, 0),
              _Actions('Wall', 100, 0),
            ]);
      }
      final weeks = await _summary();
      expect(
          weeks,
          equals([
            WeeklyDrill(
                DateTime(2017, 9, 11), DateTime(2017, 9, 17), 1200, 250, 0.0),
            WeeklyDrill(
                DateTime(2017, 9, 4), DateTime(2017, 9, 10), 1200, 250, 0.0),
            WeeklyDrill(
                DateTime(2017, 8, 28), DateTime(2017, 9, 3), 1200, 250, 0.0),
            WeeklyDrill(
                DateTime(2017, 8, 21), DateTime(2017, 8, 27), 1200, 250, 0.0),
          ]));
    });

    test('summary filters by drill', () async {
      await _addResults(
          ResultsInfo(
              startSeconds: START_SECONDS,
              drill: 'Brush Pass',
              tracking: true,
              elapsedSeconds: 1200),
          actionList: [
            _Actions('Lane', 50, 30),
            _Actions('Wall', 50, 30),
          ]);
      await _addResults(
          ResultsInfo(
              startSeconds: START_SECONDS,
              drill: 'Stick Pass',
              tracking: false,
              elapsedSeconds: 600),
          actionList: [
            _Actions('Lane', 50, 40),
            _Actions('Wall', 50, 40),
          ]);
      var weeks = await _summary(drill: 'Stick Pass');
      expect(
          weeks,
          equals([
            WeeklyDrill(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 600, 100, null),
          ]));
      weeks = await _summary(drill: 'Brush Pass');
      expect(
          weeks,
          equals([
            WeeklyDrill(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), 1200, 100, 0.6),
          ]));
    });

    test('summary filters by action', () async {
      await _addResults(
          ResultsInfo(
              startSeconds: START_SECONDS,
              drill: 'Wall & Bounce Pass',
              tracking: true,
              elapsedSeconds: 1200),
          actionList: [
            _Actions('Bounce', 50, 30),
            _Actions('Wall', 50, 30),
          ]);
      await _addResults(
          ResultsInfo(
              startSeconds: START_SECONDS,
              drill: 'Stick Pass',
              tracking: true,
              elapsedSeconds: 600),
          actionList: [
            _Actions('Lane', 50, 40),
            _Actions('Wall', 50, 40),
          ]);
      var weeks = await _summary(action: 'Lane');
      expect(
          weeks,
          equals([
            WeeklyDrill(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), null, 50, 0.8),
          ]));
      weeks = await _summary(action: 'Wall');
      expect(
          weeks,
          equals([
            WeeklyDrill(
                DateTime(2017, 7, 10), DateTime(2017, 7, 16), null, 100, 0.7),
          ]));
    });

    test('start drill', () async {
      final id = await drills
          .insertResults(ResultsInfo.newDrill(drill: 'Drill', tracking: false));
      final results = await drills.findResults(id);
      expect(results.drill, equals('Drill'));
      expect(results.startSeconds, greaterThan(0));
      expect(results.tracking, equals(false));
      expect(results.elapsedSeconds, equals(0));

      final summary = await DrillSummary.load(drills, actions, id);
      expect(summary.drill, equals('Drill'));
      expect(summary.elapsedSeconds, equals(0));
      expect(summary.good, equals(null));
      expect(summary.accuracy, equals(null));
      expect(summary.reps, equals(0));
      expect(summary.actionReps, isEmpty);
    });

    test('add action no accuracy', () async {
      final drillId = await drills.insertResults(
          ResultsInfo.newDrill(drill: 'Passing', tracking: false));
      await actions.incrementAction(drillId, 'Lane', null);
      ResultsActionsInfo lane = await actions.findAction(drillId, 'Lane');
      expect(lane.action, equals('Lane'));
      expect(lane.reps, equals(1));
      expect(lane.good, equals(null));

      await actions.incrementAction(drillId, 'Lane', null);
      await actions.incrementAction(drillId, 'Lane', null);
      await actions.incrementAction(drillId, 'Lane', null);
      lane = await actions.findAction(drillId, 'Lane');
      expect(lane.action, equals('Lane'));
      expect(lane.reps, equals(4));
      expect(lane.good, equals(null));

      final summary = await DrillSummary.load(drills, actions, drillId);
      expect(summary.drill, equals('Passing'));
      expect(summary.elapsedSeconds, equals(0));
      expect(summary.good, equals(null));
      expect(summary.accuracy, equals(null));
      expect(summary.reps, equals(4));
      // This is annoying to write because of
      // https://github.com/dart-lang/sdk/issues/32559.
      expect(summary.actionReps.entries.length, equals(1));
      expect(summary.actionReps, containsPair('Lane', 4));
    });

    test('add action with accuracy', () async {
      final drillId = await drills.insertResults(
          ResultsInfo.newDrill(drill: 'Passing', tracking: true));
      await actions.incrementAction(drillId, 'Lane', false);
      ResultsActionsInfo lane = await actions.findAction(drillId, 'Lane');
      expect(lane.action, equals('Lane'));
      expect(lane.reps, equals(1));
      expect(lane.good, equals(0));

      await actions.incrementAction(drillId, 'Lane', true);
      await actions.incrementAction(drillId, 'Lane', true);
      await actions.incrementAction(drillId, 'Lane', true);
      lane = await actions.findAction(drillId, 'Lane');
      expect(lane.action, equals('Lane'));
      expect(lane.reps, equals(4));
      expect(lane.good, equals(3));

      final summary = await DrillSummary.load(drills, actions, drillId);
      expect(summary.drill, equals('Passing'));
      expect(summary.elapsedSeconds, equals(0));
      expect(summary.good, equals(3));
      expect(summary.accuracy, equals(0.75));
      expect(summary.reps, equals(4));
    });
  });
}
