import 'dart:async';
import 'dart:collection';
import 'dart:core';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'log.dart';
import 'results_entities.dart';

part 'results_db.g.dart';

final _log = Log.get('results_db');

@dao
abstract class DrillsDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertDrill(StoredDrill results);

  @Query('SELECT * FROM Drills WHERE id = :id')
  Future<StoredDrill> loadDrill(int id);

  @Query('DELETE * FROM Drills WHERE id = :id')
  Future<void> removeDrill(int id);

  @Query('DELETE FROM Drills')
  Future<void> delete();

  @Query('''
  SELECT
    MIN(startSeconds) earliestSeconds,
    MAX(startSeconds) latestSeconds
  FROM Drills
  ''')
  Future<AllDrillDateRange> dateRange();
}

@dao
abstract class ActionsDao {
  @Query('DELETE FROM Actions')
  Future<void> delete();

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

int _secondsSinceEpoch(DateTime dt) {
  return dt.millisecondsSinceEpoch ~/ 1000;
}

DateTime _epochSecondsToDateTime(int seconds) {
  if (seconds == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
}

@DatabaseView('SELECT NULL')
class AllDrillDateRange {
  final int earliestSeconds;
  final int latestSeconds;

  DateTime get earliest => _epochSecondsToDateTime(earliestSeconds);
  DateTime get latest => _epochSecondsToDateTime(latestSeconds);

  AllDrillDateRange(this.earliestSeconds, this.latestSeconds);
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

  Future<List<DrillSummary>> loadRecentDrills(
      ResultsDatabase db, int limit, int offset) async {
    List<StoredDrill> drills = await _loadRecentStoredDrills(limit, offset);
    return _summarizeDrills(db, drills);
  }

  Future<List<DrillSummary>> loadDrillsByDate(
      ResultsDatabase db, DateTime start, DateTime end) async {
    List<StoredDrill> drills = await _loadDrillsByDate(
        _secondsSinceEpoch(start), _secondsSinceEpoch(end));
    return _summarizeDrills(db, drills);
  }

  Future<List<DrillSummary>> _summarizeDrills(
      ResultsDatabase db, List<StoredDrill> drills) async {
    Iterable<Future<DrillSummary>> summaries = drills.map((drill) async {
      Future<List<StoredAction>> actions = db.actionsDao.loadActions(drill.id);
      return _buildDrillSummary(drill, await actions);
    });
    return Future.wait(summaries);
  }

  @Query('''
  SELECT * FROM Drills
  WHERE
      startSeconds >= :startSeconds
      AND startSeconds <= :endSeconds
  ORDER BY startSeconds DESC
  ''')
  Future<List<StoredDrill>> _loadDrillsByDate(int startSeconds, int endSeconds);

  @Query('''
  SELECT * FROM Drills
  ORDER BY startSeconds DESC
  LIMIT :limit
  OFFSET :offset
  ''')
  Future<List<StoredDrill>> _loadRecentStoredDrills(int limit, int offset);

  static DrillSummary _buildDrillSummary(
      StoredDrill drill, List<StoredAction> actions) {
    final actionMap = SplayTreeMap<String, StoredAction>();
    int good = drill.tracking ? 0 : null;
    int reps = 0;
    actions.forEach((action) {
      actionMap[action.action] = action;
      reps += action.reps;
      if (good != null) {
        good += action.good;
      }
    });
    return DrillSummary(
        drill: drill, reps: reps, good: good, actions: actionMap);
  }

  // Return a weekly summary of drill progress, most recent first.
  Future<List<WeeklyDrillSummary>> loadWeeklyDrills(
      {String drill, String action, int numWeeks, int offset}) async {
    drill ??= '';
    action ??= '';
    Future<List<_WeeklyDrillTime>> times;
    // Drill time is not defined for specific actions.
    if (action.isEmpty) {
      times = _weeklyDrillTime(drill.isNotEmpty, drill, numWeeks, offset);
    } else {
      times = Future.value([]);
    }
    Future<List<_WeeklyDrillReps>> reps = _weeklyDrillReps(
        drill.isNotEmpty, drill, action.isNotEmpty, action, numWeeks, offset);
    return _mergeWeekly(await times, await reps);
  }

  @Query('''
   SELECT
     DATE(startSeconds, "unixepoch", "localtime", "weekday 0", "-6 days") startDay,
     DATE(startSeconds, "unixepoch", "localtime", "weekday 0") endDay,
     SUM(elapsedSeconds) elapsedSeconds
   FROM Drills
   WHERE
     (NOT :matchDrill OR drill = :drill) 
   GROUP BY startDay
   ORDER BY startDay DESC
   LIMIT :numWeeks
   OFFSET :offset
  ''')
  Future<List<_WeeklyDrillTime>> _weeklyDrillTime(
      bool matchDrill, String drill, int numWeeks, int offset);

  @Query('''
   SELECT
     DATE(startSeconds, "unixepoch", "localtime", "weekday 0", "-6 days") startDay,
     DATE(startSeconds, "unixepoch", "localtime", "weekday 0") endDay,
     IFNULL(SUM(reps), 0) reps,
     (CAST(SUM(CASE WHEN Drills.tracking THEN Actions.good ELSE 0 END) AS DOUBLE) / 
      CAST(SUM(CASE WHEN Drills.tracking THEN Actions.reps ELSE 0 END) AS DOUBLE)) accuracy
   FROM Drills
   LEFT JOIN Actions ON Drills.id = Actions.drillId
   WHERE
     (NOT :matchDrill OR drill = :drill) 
     AND (NOT :matchAction OR action = :action)
   GROUP BY startDay
   ORDER BY startDay DESC
   LIMIT :numWeeks
   OFFSET :offset
  ''')
  Future<List<_WeeklyDrillReps>> _weeklyDrillReps(bool matchDrill, String drill,
      bool matchAction, String action, int numWeeks, int offset);

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
        a.startDay.compareTo(b.startDay));
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

class ActionSummary {
  final String action;
  final int reps;
  final int goodCount;

  ActionSummary(this.action, this.reps, this.goodCount);
}

@Database(version: 1, entities: [
  StoredDrill,
  StoredAction,
], views: [
  AllDrillDateRange,
  _WeeklyDrillTime,
  _WeeklyDrillReps,
])
abstract class ResultsDatabase extends FloorDatabase {
  DrillsDao get drillsDao;
  ActionsDao get actionsDao;
  SummariesDao get summariesDao;

  static Future<ResultsDatabase> init() {
    return $FloorResultsDatabase.databaseBuilder('results3.db').build();
  }

  Future<void> addData(StoredDrill results,
      {List<ActionSummary> actionList}) async {
    final id = await drillsDao.insertDrill(results);
    actionList ??= [];
    await Future.forEach(actionList, (action) async {
      for (int i = 0; i < action.reps; ++i) {
        bool isGood;
        if (results.tracking) {
          isGood = (i < action.goodCount);
        }
        await actionsDao.incrementAction(id, action.action, isGood);
      }
    });
  }

  Future<void> deleteAll() async {
    await actionsDao.delete();
    await drillsDao.delete();
  }
}
