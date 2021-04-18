import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'results_info.dart';

part 'results_db.g.dart';

@dao
abstract class DrillsDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertResults(ResultsInfo results);

  @Query('SELECT * FROM Drills WHERE id = :id')
  Future<ResultsInfo> findResults(int id);
}

@dao
abstract class ActionsDao {
  @Query('SELECT * from Actions WHERE drillId = :drillId AND action = :action')
  Future<ResultsActionsInfo> findAction(int drillId, String action);

  @Query('SELECT * from Actions WHERE drillId = :drillId')
  Future<List<ResultsActionsInfo>> findActions(int drillId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertAction(ResultsActionsInfo results);

  @transaction
  Future<void> incrementAction(int drillId, String action, bool good) async {
    ResultsActionsInfo actionInfo = await findAction(drillId, action);
    if (actionInfo == null) {
      actionInfo = ResultsActionsInfo(
          drillId: drillId,
          action: action,
          reps: 0,
          good: good != null ? 0 : null);
    }
    ++actionInfo.reps;
    if (actionInfo.good != null && good) {
      ++actionInfo.good;
    }
    await insertAction(actionInfo);
  }
}

// Summary of results for a single drill.
class DrillSummary {
  final String drill;
  final int reps;
  final int elapsedSeconds;
  final int good; // nullable
  final double accuracy; // nullable
  // use SplayTreeMap for implementation.
  final Map<String, int> actionReps;

  DrillSummary(
      {this.drill,
      this.reps,
      this.elapsedSeconds,
      this.good,
      this.accuracy,
      this.actionReps});

  static Future<DrillSummary> load(
      DrillsDao drills, ActionsDao actions, int drillId) async {
    // Could optimize this into a single more complex SQL query, but it doesn't
    // seem worth it.
    Future<ResultsInfo> futureResults = drills.findResults(drillId);
    Future<List<ResultsActionsInfo>> futureCounts =
        actions.findActions(drillId);
    final results = await futureResults;
    final counts = await futureCounts;
    final actionReps = SplayTreeMap<String, int>();
    int good = results.tracking ? 0 : null;
    int reps = 0;
    for (final action in counts) {
      actionReps[action.action] = action.reps;
      reps += action.reps;
      if (good != null) {
        good += action.good;
      }
    }
    final accuracy = (reps > 0 && good != null) ? (good / reps) : null;
    return DrillSummary(
        drill: results.drill,
        elapsedSeconds: results.elapsedSeconds,
        reps: reps,
        good: good,
        accuracy: accuracy,
        actionReps: actionReps);
  }
}

/// Summary of drill results by day.
class WeeklyDrill extends Equatable {
  final DateTime startDay;
  final DateTime endDay;
  final int elapsedSeconds;
  final int reps;
  final double accuracy;

  WeeklyDrill(this.startDay, this.endDay, this.elapsedSeconds, this.reps,
      this.accuracy);

  @override
  List<Object> get props => [startDay, endDay, elapsedSeconds, reps, accuracy];
}

class _WeeklyDrillBuilder {
  DateTime startDay;
  DateTime endDay;
  int elapsedSeconds;
  int reps;
  double accuracy;

  WeeklyDrill build() {
    return WeeklyDrill(startDay, endDay, elapsedSeconds, reps, accuracy);
  }
}

// Weekly drill time summary. Used as DB view via SummariesDao, not directly.
@DatabaseView('SELECT NULL')
class _WeeklyDrillTime {
  final String startDay;
  final String endDay;
  final int elapsedSeconds;

  _WeeklyDrillTime(this.startDay, this.endDay, this.elapsedSeconds);
}

// Weekly drill reps summary. Used as DB view via SummariesDao, not directly.
@DatabaseView('SELECT NULL')
class _WeeklyDrillReps {
  final String startDay;
  final String endDay;
  final int reps;
  final double accuracy;

  _WeeklyDrillReps(this.startDay, this.endDay, this.reps, this.accuracy);
}

// Useful notes on Floor/SQL translation.
// - if you forget @DatabaseView annotation on the output of a query, you get
//   get a compilation error: "The getter 'constructor' was called on null."
// - you also get that error if you forget to list the view on the @Database
//   annotation.
// - the query argument @DatabaseView is mandatory, but is not required to be
//   used. SELECT NULL works just fine.
// - arguments are substituted in order, not by name. This means that arguments
//   may only appear in the SQL query once, and that they must appear in the
//   same order as in the function signature.
// - if you reference an argument more than once, you'll see an error like
//   "SQL query arguments and method parameters have to match."
// - if you reference arguments in the wrong order AND you're very lucky, you'll
//   get a runtime type error from SQLite about argument type mismatches. If
//   you're unlucky, your query will just do the wrong thing.
@dao
abstract class SummariesDao {
  @Query('''
   SELECT
     DATE(startSeconds, "unixepoch", "weekday 0", "-6 days") startDay,
     DATE(startSeconds, "unixepoch", "weekday 0") endDay,
     SUM(elapsedSeconds) elapsedSeconds
   FROM Drills
   WHERE
     startSeconds < :endSeconds
     AND (NOT :matchDrill OR drill = :drill) 
   GROUP BY startDay
   ORDER BY startDay DESC
   LIMIT :numWeeks
  ''')
  Future<List<_WeeklyDrillTime>> _weeklyDrillTime(
      int endSeconds, bool matchDrill, String drill, int numWeeks);

  @Query('''
   SELECT
     DATE(startSeconds, "unixepoch", "weekday 0", "-6 days") startDay,
     DATE(startSeconds, "unixepoch", "weekday 0") endDay,
     IFNULL(SUM(reps), 0) reps,
     CAST(SUM(IIF(Drills.tracking, Actions.good, 0)) AS DOUBLE)
       / CAST(SUM(IIF(drills.tracking, Actions.reps, 0)) AS DOUBLE) accuracy
   FROM Drills
   LEFT JOIN Actions ON Drills.id = Actions.drillId
   WHERE
     startSeconds < :endSeconds
     AND (NOT :matchDrill OR drill = :drill) 
     AND (NOT :matchAction OR action = :action)
   GROUP BY startDay
   ORDER BY startDay DESC
   LIMIT :numWeeks
  ''')
  Future<List<_WeeklyDrillReps>> _weeklyDrillReps(
      int endSeconds,
      bool matchDrill,
      String drill,
      bool matchAction,
      String action,
      int numWeeks);

  // Return a weekly summary of drill progress, most recent first.
  Future<List<WeeklyDrill>> weeklyDrills(
      {int endSeconds, int numWeeks, String drill, String action}) async {
    drill ??= '';
    action ??= '';
    Future<List<_WeeklyDrillTime>> times;
    // Drill time is not defined for specific actions.
    if (action.isEmpty) {
      times = _weeklyDrillTime(endSeconds, drill.isNotEmpty, drill, numWeeks);
    } else {
      times = Future.value([]);
    }
    Future<List<_WeeklyDrillReps>> reps = _weeklyDrillReps(endSeconds,
        drill.isNotEmpty, drill, action.isNotEmpty, action, numWeeks);
    return _mergeWeekly(await times, await reps);
  }

  List<WeeklyDrill> _mergeWeekly(
      List<_WeeklyDrillTime> times, List<_WeeklyDrillReps> reps) {
    final builders = Map<String, _WeeklyDrillBuilder>();
    for (_WeeklyDrillTime time in times) {
      _WeeklyDrillBuilder b = _getBuilder(builders, time.startDay, time.endDay);
      b.elapsedSeconds = time.elapsedSeconds;
    }
    for (_WeeklyDrillReps rep in reps) {
      _WeeklyDrillBuilder b = _getBuilder(builders, rep.startDay, rep.endDay);
      b.reps = rep.reps;
      b.accuracy = rep.accuracy;
    }
    List<WeeklyDrill> out = [];
    for (_WeeklyDrillBuilder b in builders.values) {
      out.add(b.build());
    }
    out.sort(
        (WeeklyDrill a, WeeklyDrill b) => b.startDay.compareTo(a.startDay));
    return out;
  }

  _WeeklyDrillBuilder _getBuilder(Map<String, _WeeklyDrillBuilder> builders,
      String startDay, String endDay) {
    _WeeklyDrillBuilder b = builders[startDay];
    if (b == null) {
      b = _WeeklyDrillBuilder();
      b.startDay = DateTime.parse(startDay);
      b.endDay = DateTime.parse(endDay);
      builders[startDay] = b;
    }
    return b;
  }
}

// TODO(brian): add summary/history views of this database.
// time and reps and accuracy overall
// time and reps and accuracy for drill
// time and reps and accuracy for action
@Database(
    version: 1,
    entities: [ResultsInfo, ResultsActionsInfo],
    views: [_WeeklyDrillTime, _WeeklyDrillReps])
abstract class ResultsDatabase extends FloorDatabase {
  DrillsDao get drillsDao;
  ActionsDao get actionsDao;
  SummariesDao get summariesDao;
}
