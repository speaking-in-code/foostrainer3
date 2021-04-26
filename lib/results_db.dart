import 'dart:async';
import 'dart:collection';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'results_entities.dart';

part 'results_db.g.dart';

@dao
abstract class DrillsDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertDrill(StoredDrill results);

  @Query('SELECT * FROM Drills WHERE id = :id')
  Future<StoredDrill> loadDrill(int id);
}

@dao
abstract class ActionsDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertAction(StoredAction results);

  @Query('SELECT * from Actions WHERE drillId = :drillId AND action = :action')
  Future<StoredAction> loadAction(int drillId, String action);

  @Query('SELECT * from Actions WHERE drillId = :drillId')
  Future<List<StoredAction>> loadActions(int drillId);

  @transaction
  Future<void> incrementAction(int drillId, String action, bool good) async {
    final actionInfo = await loadAction(drillId, action);
    int id = actionInfo?.id;
    int reps = (actionInfo?.reps ?? 0) + 1;
    int goodCount;
    if (actionInfo == null) {
      if (good != null) {
        goodCount = good ? 1 : 0;
      }
    } else if (actionInfo.good != null) {
      goodCount = actionInfo.good;
      if (good) {
        ++goodCount;
      }
    }
    await insertAction(StoredAction(
        id: id, drillId: drillId, action: action, reps: reps, good: goodCount));
  }
}

class _WeeklyDrillSummaryBuilder {
  DateTime startDay;
  DateTime endDay;
  int elapsedSeconds;
  int reps;
  double accuracy;

  WeeklyDrillSummary build() {
    return WeeklyDrillSummary(startDay, endDay, elapsedSeconds, reps, accuracy);
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
  Future<DrillSummary> loadDrill(ResultsDatabase db, int drillId) async {
    Future<StoredDrill> drill = db.drillsDao.loadDrill(drillId);
    Future<List<StoredAction>> actions = db.actionsDao.loadActions(drillId);
    return _buildDrillSummary(await drill, await actions);
  }

  static DrillSummary _buildDrillSummary(
      StoredDrill drill, List<StoredAction> actions) {
    final actionReps = SplayTreeMap<String, int>();
    int good = drill.tracking ? 0 : null;
    int reps = 0;
    actions.forEach((action) {
      actionReps[action.action] = action.reps;
      reps += action.reps;
      if (good != null) {
        good += action.good;
      }
    });
    final accuracy = (reps > 0 && good != null) ? (good / reps) : null;
    return DrillSummary(
        drill: drill,
        reps: reps,
        good: good,
        accuracy: accuracy,
        actionReps: actionReps);
  }

  // Return a weekly summary of drill progress, most recent first.
  Future<List<WeeklyDrillSummary>> weeklyDrills(
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

  List<WeeklyDrillSummary> _mergeWeekly(
      List<_WeeklyDrillTime> times, List<_WeeklyDrillReps> reps) {
    final builders = Map<String, _WeeklyDrillSummaryBuilder>();
    times.forEach((time) {
      _WeeklyDrillSummaryBuilder b =
          _getBuilder(builders, time.startDay, time.endDay);
      b.elapsedSeconds = time.elapsedSeconds;
    });
    reps.forEach((rep) {
      _WeeklyDrillSummaryBuilder b =
          _getBuilder(builders, rep.startDay, rep.endDay);
      b.reps = rep.reps;
      b.accuracy = rep.accuracy;
    });
    List<WeeklyDrillSummary> out =
        builders.values.map((b) => b.build()).toList();
    out.sort((WeeklyDrillSummary a, WeeklyDrillSummary b) =>
        b.startDay.compareTo(a.startDay));
    return out;
  }

  _WeeklyDrillSummaryBuilder _getBuilder(
      Map<String, _WeeklyDrillSummaryBuilder> builders,
      String startDay,
      String endDay) {
    return builders.putIfAbsent(
        startDay,
        () => _WeeklyDrillSummaryBuilder()
          ..startDay = DateTime.parse(startDay)
          ..endDay = DateTime.parse(endDay));
  }
}

@Database(
    version: 1,
    entities: [StoredDrill, StoredAction],
    views: [_WeeklyDrillTime, _WeeklyDrillReps])
abstract class ResultsDatabase extends FloorDatabase {
  DrillsDao get drillsDao;
  ActionsDao get actionsDao;
  SummariesDao get summariesDao;

  static Future<ResultsDatabase> init() {
    return $FloorResultsDatabase.databaseBuilder('results3.db').build();
  }
}
