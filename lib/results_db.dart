import 'dart:async';
import 'dart:collection';
import 'dart:core';

import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';
import 'package:meta/meta.dart';
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

  // Remove the drill with specified id.
  @transaction
  Future<void> removeDrill(int id) async {
    await _removeActions(id);
    return _internalRemovalDrill(id);
  }

  @Query('DELETE FROM Actions WHERE drillId = :id')
  Future<void> _removeActions(int id);

  @Query('DELETE FROM Drills WHERE id = :id')
  Future<void> _internalRemovalDrill(int id);

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

class _AggregateDrillSummaryBuilder {
  DateTime startDay;
  DateTime endDay;
  int elapsedSeconds;
  int reps;
  double accuracy;

  AggregatedDrillSummary build() {
    return AggregatedDrillSummary(
        startDay, endDay, elapsedSeconds, reps, accuracy);
  }
}

// Weekly drill time summary. Used as DB view via SummariesDao, not directly.
@DatabaseView('SELECT NULL')
class _AggregatedDrillTime {
  final String startDay;
  final String endDay;
  final int elapsedSeconds;

  _AggregatedDrillTime(this.startDay, this.endDay, this.elapsedSeconds);
}

// Weekly drill reps summary. Used as DB view via SummariesDao, not directly.
@DatabaseView('SELECT NULL')
class _AggregatedDrillReps {
  final String startDay;
  final String endDay;
  final int reps;
  final double accuracy;

  _AggregatedDrillReps(this.startDay, this.endDay, this.reps, this.accuracy);
}

// Aggregated action reps summary. Used as DB view via SummariesDao, not directly.
@DatabaseView('SELECT NULL')
class AggregatedActionReps extends Equatable {
  final String startDayStr;
  @ignore
  final DateTime startDay;
  final String endDayStr;
  @ignore
  final DateTime endDay;
  final String action;
  final int reps;
  final double accuracy;

  AggregatedActionReps(
      this.startDayStr, this.endDayStr, this.action, this.reps, this.accuracy)
      : startDay = DateTime.parse(startDayStr),
        endDay = DateTime.parse(endDayStr);

  @override
  List<Object> get props => [startDay, endDay, action, reps, accuracy];
}

class AggregatedActionRepsBuilder {
  String startDayStr;
  String endDayStr;
  String action;
  int reps = 0;
  int trackedReps = 0;
  int trackedGood = 0;

  AggregatedActionReps build() {
    double accuracy;
    if (trackedReps > 0) {
      accuracy = trackedGood / trackedReps;
    }
    return AggregatedActionReps(startDayStr, endDayStr, action, reps, accuracy);
  }
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

enum AggregationLevel {
  DAILY,
  WEEKLY,
  MONTHLY,
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

  Future<List<DrillSummary>> loadDrillsByDate(ResultsDatabase db,
      {@required int limit,
      @required int offset,
      String fullName,
      DateTime start,
      DateTime end}) async {
    assert(limit != null);
    assert(offset != null);
    int startSeconds = start != null ? _secondsSinceEpoch(start) : 0;
    int endSeconds = end != null ? _secondsSinceEpoch(end) : 0;
    List<StoredDrill> drills = await _loadDrillsByDate(
        start != null,
        startSeconds,
        endSeconds,
        fullName != null,
        fullName ?? '',
        limit,
        offset);
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
      (NOT :matchDate OR (startSeconds >= :startSeconds AND startSeconds <= :endSeconds))
      AND (NOT :matchName OR drill = :fullName)
  ORDER BY startSeconds DESC
  LIMIT :limit
  OFFSET :offset
  ''')
  Future<List<StoredDrill>> _loadDrillsByDate(bool matchDate, int startSeconds,
      int endSeconds, bool matchName, String fullName, int limit, int offset);

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

  // Return an aggregation of drill progress at the specified aggregation evel.
  Future<List<AggregatedDrillSummary>> loadAggregateDrills(
      {@required AggregationLevel aggLevel,
      @required int numWeeks,
      @required int offset,
      String drill,
      String action}) async {
    drill ??= '';
    action ??= '';
    Future<List<_AggregatedDrillTime>> times = Future.value([]);
    // Drill time is not defined for specific actions.
    if (action.isEmpty) {
      times = _drillTime(
          aggLevel: aggLevel, drill: drill, numWeeks: numWeeks, offset: offset);
    }
    Future<List<_AggregatedDrillReps>> reps = _drillReps(
        aggLevel: aggLevel,
        drill: drill,
        action: action,
        numWeeks: numWeeks,
        offset: offset);
    return _mergeAggegate(await times, await reps);
  }

  List<AggregatedDrillSummary> _mergeAggegate(
      List<_AggregatedDrillTime> times, List<_AggregatedDrillReps> reps) {
    final builders = Map<String, _AggregateDrillSummaryBuilder>();
    times.forEach((time) {
      _AggregateDrillSummaryBuilder b =
          _getBuilder(builders, time.startDay, time.endDay);
      b.elapsedSeconds = time.elapsedSeconds;
    });
    reps.forEach((rep) {
      _AggregateDrillSummaryBuilder b =
          _getBuilder(builders, rep.startDay, rep.endDay);
      b.reps = rep.reps;
      b.accuracy = rep.accuracy;
    });
    List<AggregatedDrillSummary> out =
        builders.values.map((b) => b.build()).toList();
    out.sort((AggregatedDrillSummary a, AggregatedDrillSummary b) =>
        a.startDay.compareTo(b.startDay));
    return out;
  }

  _AggregateDrillSummaryBuilder _getBuilder(
      Map<String, _AggregateDrillSummaryBuilder> builders,
      String startDay,
      String endDay) {
    return builders.putIfAbsent(
        startDay,
        () => _AggregateDrillSummaryBuilder()
          ..startDay = DateTime.parse(startDay)
          ..endDay = DateTime.parse(endDay));
  }

  Future<List<_AggregatedDrillTime>> _drillTime(
      {@required AggregationLevel aggLevel,
      @required int numWeeks,
      @required int offset,
      String drill}) {
    switch (aggLevel) {
      case AggregationLevel.DAILY:
        return _dailyDrillTime(drill.isNotEmpty, drill, numWeeks, offset);
      case AggregationLevel.WEEKLY:
        return _weeklyDrillTime(drill.isNotEmpty, drill, numWeeks, offset);
      case AggregationLevel.MONTHLY:
        return _monthlyDrillTime(drill.isNotEmpty, drill, numWeeks, offset);
      default:
        throw ArgumentError('Unknown aggLevel $aggLevel');
    }
  }

  Future<List<_AggregatedDrillReps>> _drillReps(
      {@required AggregationLevel aggLevel,
      @required int numWeeks,
      @required int offset,
      String drill,
      String action}) {
    switch (aggLevel) {
      case AggregationLevel.DAILY:
        return _dailyDrillReps(drill.isNotEmpty, drill, action.isNotEmpty,
            action, numWeeks, offset);
      case AggregationLevel.WEEKLY:
        return _weeklyDrillReps(drill.isNotEmpty, drill, action.isNotEmpty,
            action, numWeeks, offset);
      case AggregationLevel.MONTHLY:
        return _monthlyDrillReps(drill.isNotEmpty, drill, action.isNotEmpty,
            action, numWeeks, offset);
      default:
        throw ArgumentError('Unknown aggLevel $aggLevel');
    }
  }

  @Query('''
   SELECT
     DATE(startSeconds, "unixepoch", "localtime", "start of day") startDay,
     DATE(startSeconds, "unixepoch", "localtime", "start of day", "+1 day") endDay,
     SUM(elapsedSeconds) elapsedSeconds
   FROM Drills
   WHERE
     (NOT :matchDrill OR drill = :drill) 
   GROUP BY startDay
   ORDER BY startDay DESC
   LIMIT :numWeeks
   OFFSET :offset
  ''')
  Future<List<_AggregatedDrillTime>> _dailyDrillTime(
      bool matchDrill, String drill, int numWeeks, int offset);

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
  Future<List<_AggregatedDrillTime>> _weeklyDrillTime(
      bool matchDrill, String drill, int numWeeks, int offset);

  @Query('''
   SELECT
     DATE(startSeconds, "unixepoch", "localtime", "start of month") startDay,
     DATE(startSeconds, "unixepoch", "localtime", "start of month", "+1 month") endDay,
     SUM(elapsedSeconds) elapsedSeconds
   FROM Drills
   WHERE
     (NOT :matchDrill OR drill = :drill) 
   GROUP BY startDay
   ORDER BY startDay DESC
   LIMIT :numWeeks
   OFFSET :offset
  ''')
  Future<List<_AggregatedDrillTime>> _monthlyDrillTime(
      bool matchDrill, String drill, int numWeeks, int offset);

  @Query('''
   SELECT
     DATE(startSeconds, "unixepoch", "localtime", "start of day") startDay,
     DATE(startSeconds, "unixepoch", "localtime", "start of day", "+1 day") endDay,
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
  Future<List<_AggregatedDrillReps>> _dailyDrillReps(bool matchDrill,
      String drill, bool matchAction, String action, int numWeeks, int offset);

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
  Future<List<_AggregatedDrillReps>> _weeklyDrillReps(bool matchDrill,
      String drill, bool matchAction, String action, int numWeeks, int offset);

  @Query('''
   SELECT
     DATE(startSeconds, "unixepoch", "localtime", "start of month") startDay,
     DATE(startSeconds, "unixepoch", "localtime", "start of month", "+1 month") endDay,
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
  Future<List<_AggregatedDrillReps>> _monthlyDrillReps(bool matchDrill,
      String drill, bool matchAction, String action, int numWeeks, int offset);

  // TODO(brian): this limit statement here is incorrect, it's not limiting by
  // num weeks, it's limiting by number of rows.
  @Query('''
   SELECT
     DATE(startSeconds, "unixepoch", "localtime", "weekday 0", "-6 days") startDayStr,
     DATE(startSeconds, "unixepoch", "localtime", "weekday 0") endDayStr,
     Actions.action action,
     IFNULL(SUM(reps), 0) reps,
     (CAST(SUM(CASE WHEN Drills.tracking THEN Actions.good ELSE 0 END) AS DOUBLE) / 
      CAST(SUM(CASE WHEN Drills.tracking THEN Actions.reps ELSE 0 END) AS DOUBLE)) accuracy
   FROM Drills
   LEFT JOIN Actions ON Drills.id = Actions.drillId
   WHERE
     drill = :drill 
   GROUP BY startDayStr, action
   ORDER BY startDayStr DESC, action
   LIMIT :numWeeks
   OFFSET :offset
  ''')
  Future<List<AggregatedActionReps>> loadWeeklyActionReps(
      String drill, int numWeeks, int offset);
}

class ActionSummary {
  final String action;
  final int reps;
  final int goodCount;

  ActionSummary(this.action, this.reps, this.goodCount);
}

final renameStickPassMigration =
    Migration(1, 2, (sqflite.DatabaseExecutor database) async {
  _log.info('Migrating "Pass" to "Stick Pass"');
  final changed = await database.rawUpdate('''
  UPDATE Drills
    SET drill = 'Stick Pass' || SUBSTR(drill, 5)
    WHERE drill LIKE 'Pass:%'
  ''');
  _log.info('Migrated $changed records');
});

@Database(version: 2, entities: [
  StoredDrill,
  StoredAction,
], views: [
  AllDrillDateRange,
  _AggregatedDrillTime,
  _AggregatedDrillReps,
  AggregatedActionReps,
])
abstract class ResultsDatabase extends FloorDatabase {
  DrillsDao get drillsDao;
  ActionsDao get actionsDao;
  SummariesDao get summariesDao;

  static Future<ResultsDatabase> init() {
    return $FloorResultsDatabase
        .databaseBuilder('results3.db')
        .addMigrations([renameStickPassMigration]).build();
  }

  Future<int> addData(StoredDrill results,
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
    return id;
  }

  Future<void> deleteAll() async {
    await actionsDao.delete();
    await drillsDao.delete();
  }
}
