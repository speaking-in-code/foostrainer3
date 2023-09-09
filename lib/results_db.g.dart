// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'results_db.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorResultsDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$ResultsDatabaseBuilder databaseBuilder(String name) =>
      _$ResultsDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$ResultsDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$ResultsDatabaseBuilder(null);
}

class _$ResultsDatabaseBuilder {
  _$ResultsDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$ResultsDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$ResultsDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<ResultsDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$ResultsDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$ResultsDatabase extends ResultsDatabase {
  _$ResultsDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  DrillsDao? _drillsDaoInstance;

  ActionsDao? _actionsDaoInstance;

  SummariesDao? _summariesDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 2,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Drills` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `startSeconds` INTEGER NOT NULL, `drill` TEXT NOT NULL, `tracking` INTEGER NOT NULL, `elapsedSeconds` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Actions` (`id` INTEGER, `drillId` INTEGER NOT NULL, `action` TEXT NOT NULL, `reps` INTEGER NOT NULL, `good` INTEGER, FOREIGN KEY (`drillId`) REFERENCES `Drills` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');

        await database.execute(
            'CREATE VIEW IF NOT EXISTS `AllDrillDateRange` AS SELECT NULL');
        await database.execute(
            'CREATE VIEW IF NOT EXISTS `_AggregatedDrillTime` AS SELECT NULL');
        await database.execute(
            'CREATE VIEW IF NOT EXISTS `_AggregatedDrillReps` AS SELECT NULL');
        await database.execute(
            'CREATE VIEW IF NOT EXISTS `AggregatedActionReps` AS SELECT NULL');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  DrillsDao get drillsDao {
    return _drillsDaoInstance ??= _$DrillsDao(database, changeListener);
  }

  @override
  ActionsDao get actionsDao {
    return _actionsDaoInstance ??= _$ActionsDao(database, changeListener);
  }

  @override
  SummariesDao get summariesDao {
    return _summariesDaoInstance ??= _$SummariesDao(database, changeListener);
  }
}

class _$DrillsDao extends DrillsDao {
  _$DrillsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _storedDrillInsertionAdapter = InsertionAdapter(
            database,
            'Drills',
            (StoredDrill item) => <String, Object?>{
                  'id': item.id,
                  'startSeconds': item.startSeconds,
                  'drill': item.drill,
                  'tracking': item.tracking ? 1 : 0,
                  'elapsedSeconds': item.elapsedSeconds
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<StoredDrill> _storedDrillInsertionAdapter;

  @override
  Future<StoredDrill?> loadDrill(int id) async {
    return _queryAdapter.query('SELECT * FROM Drills WHERE id = ?1',
        mapper: (Map<String, Object?> row) => StoredDrill(
            id: row['id'] as int?,
            startSeconds: row['startSeconds'] as int,
            drill: row['drill'] as String,
            tracking: (row['tracking'] as int) != 0,
            elapsedSeconds: row['elapsedSeconds'] as int),
        arguments: [id]);
  }

  @override
  Future<void> _removeActions(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM Actions WHERE drillId = ?1',
        arguments: [id]);
  }

  @override
  Future<void> _internalRemovalDrill(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM Drills WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> delete() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Drills');
  }

  @override
  Future<AllDrillDateRange?> dateRange() async {
    return _queryAdapter.query(
        'SELECT     MIN(startSeconds) earliestSeconds,     MAX(startSeconds) latestSeconds   FROM Drills',
        mapper: (Map<String, Object?> row) => AllDrillDateRange(
            row['earliestSeconds'] as int?, row['latestSeconds'] as int?));
  }

  @override
  Future<int> insertDrill(StoredDrill results) {
    return _storedDrillInsertionAdapter.insertAndReturnId(
        results, OnConflictStrategy.replace);
  }

  @override
  Future<void> removeDrill(int id) async {
    if (database is sqflite.Transaction) {
      await super.removeDrill(id);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$ResultsDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.drillsDao.removeDrill(id);
      });
    }
  }
}

class _$ActionsDao extends ActionsDao {
  _$ActionsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _storedActionInsertionAdapter = InsertionAdapter(
            database,
            'Actions',
            (StoredAction item) => <String, Object?>{
                  'id': item.id,
                  'drillId': item.drillId,
                  'action': item.action,
                  'reps': item.reps,
                  'good': item.good
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<StoredAction> _storedActionInsertionAdapter;

  @override
  Future<void> delete() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Actions');
  }

  @override
  Future<StoredAction?> loadAction(
    int drillId,
    String action,
  ) async {
    return _queryAdapter.query(
        'SELECT * from Actions WHERE drillId = ?1 AND action = ?2',
        mapper: (Map<String, Object?> row) => StoredAction(
            id: row['id'] as int?,
            drillId: row['drillId'] as int,
            action: row['action'] as String,
            reps: row['reps'] as int?,
            good: row['good'] as int?),
        arguments: [drillId, action]);
  }

  @override
  Future<List<StoredAction>> loadActions(int drillId) async {
    return _queryAdapter.queryList('SELECT * from Actions WHERE drillId = ?1',
        mapper: (Map<String, Object?> row) => StoredAction(
            id: row['id'] as int?,
            drillId: row['drillId'] as int,
            action: row['action'] as String,
            reps: row['reps'] as int?,
            good: row['good'] as int?),
        arguments: [drillId]);
  }

  @override
  Future<int> insertAction(StoredAction results) {
    return _storedActionInsertionAdapter.insertAndReturnId(
        results, OnConflictStrategy.replace);
  }

  @override
  Future<void> incrementAction(
    int drillId,
    String action,
    ActionUpdate trackingResult,
  ) async {
    if (database is sqflite.Transaction) {
      await super.incrementAction(drillId, action, trackingResult);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$ResultsDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.actionsDao
            .incrementAction(drillId, action, trackingResult);
      });
    }
  }
}

class _$SummariesDao extends SummariesDao {
  _$SummariesDao(
    this.database,
    this.changeListener,
  ) : _queryAdapter = QueryAdapter(database);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  @override
  Future<List<StoredDrill>> _loadDrillsByDate(
    bool matchDate,
    int startSeconds,
    int endSeconds,
    bool matchName,
    String fullName,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Drills   WHERE       (NOT ?1 OR (startSeconds >= ?2 AND startSeconds <= ?3))       AND (NOT ?4 OR drill = ?5)   ORDER BY startSeconds DESC   LIMIT ?6   OFFSET ?7',
        mapper: (Map<String, Object?> row) => StoredDrill(
            id: row['id'] as int?,
            startSeconds: row['startSeconds'] as int,
            drill: row['drill'] as String,
            tracking: (row['tracking'] as int) != 0,
            elapsedSeconds: row['elapsedSeconds'] as int),
        arguments: [
          matchDate ? 1 : 0,
          startSeconds,
          endSeconds,
          matchName ? 1 : 0,
          fullName,
          limit,
          offset
        ]);
  }

  @override
  Future<List<StoredDrill>> _loadDrillsByDateNoLimit(
    bool matchDate,
    int startSeconds,
    int endSeconds,
    bool matchName,
    String fullName,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Drills   WHERE       (NOT ?1 OR (startSeconds >= ?2 AND startSeconds <= ?3))       AND (NOT ?4 OR drill = ?5)   ORDER BY startSeconds DESC',
        mapper: (Map<String, Object?> row) => StoredDrill(id: row['id'] as int?, startSeconds: row['startSeconds'] as int, drill: row['drill'] as String, tracking: (row['tracking'] as int) != 0, elapsedSeconds: row['elapsedSeconds'] as int),
        arguments: [
          matchDate ? 1 : 0,
          startSeconds,
          endSeconds,
          matchName ? 1 : 0,
          fullName
        ]);
  }

  @override
  Future<List<_AggregatedDrillTime>> _dailyDrillTime(
    bool matchDrill,
    String drill,
    int numWeeks,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT      DATE(startSeconds, \"unixepoch\", \"localtime\", \"start of day\") startDay,      DATE(startSeconds, \"unixepoch\", \"localtime\", \"start of day\", \"+1 day\") endDay,      SUM(elapsedSeconds) elapsedSeconds    FROM Drills    WHERE      (NOT ?1 OR drill = ?2)     GROUP BY startDay    ORDER BY startDay DESC    LIMIT ?3    OFFSET ?4',
        mapper: (Map<String, Object?> row) => _AggregatedDrillTime(row['startDay'] as String, row['endDay'] as String, row['elapsedSeconds'] as int),
        arguments: [matchDrill ? 1 : 0, drill, numWeeks, offset]);
  }

  @override
  Future<List<_AggregatedDrillTime>> _weeklyDrillTime(
    bool matchDrill,
    String drill,
    int numWeeks,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT      DATE(startSeconds, \"unixepoch\", \"localtime\", \"weekday 0\", \"-6 days\") startDay,      DATE(startSeconds, \"unixepoch\", \"localtime\", \"weekday 0\") endDay,      SUM(elapsedSeconds) elapsedSeconds    FROM Drills    WHERE      (NOT ?1 OR drill = ?2)     GROUP BY startDay    ORDER BY startDay DESC    LIMIT ?3    OFFSET ?4',
        mapper: (Map<String, Object?> row) => _AggregatedDrillTime(row['startDay'] as String, row['endDay'] as String, row['elapsedSeconds'] as int),
        arguments: [matchDrill ? 1 : 0, drill, numWeeks, offset]);
  }

  @override
  Future<List<_AggregatedDrillTime>> _monthlyDrillTime(
    bool matchDrill,
    String drill,
    int numWeeks,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT      DATE(startSeconds, \"unixepoch\", \"localtime\", \"start of month\") startDay,      DATE(startSeconds, \"unixepoch\", \"localtime\", \"start of month\", \"+1 month\") endDay,      SUM(elapsedSeconds) elapsedSeconds    FROM Drills    WHERE      (NOT ?1 OR drill = ?2)     GROUP BY startDay    ORDER BY startDay DESC    LIMIT ?3    OFFSET ?4',
        mapper: (Map<String, Object?> row) => _AggregatedDrillTime(row['startDay'] as String, row['endDay'] as String, row['elapsedSeconds'] as int),
        arguments: [matchDrill ? 1 : 0, drill, numWeeks, offset]);
  }

  @override
  Future<List<_AggregatedDrillReps>> _dailyDrillReps(
    bool matchDrill,
    String drill,
    bool matchAction,
    String action,
    int numWeeks,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT      DATE(startSeconds, \"unixepoch\", \"localtime\", \"start of day\") startDay,      DATE(startSeconds, \"unixepoch\", \"localtime\", \"start of day\", \"+1 day\") endDay,      IFNULL(SUM(reps), 0) reps,      (CAST(SUM(CASE WHEN Drills.tracking THEN Actions.good ELSE 0 END) AS DOUBLE) /        CAST(SUM(CASE WHEN Drills.tracking THEN Actions.reps ELSE 0 END) AS DOUBLE)) accuracy    FROM Drills    LEFT JOIN Actions ON Drills.id = Actions.drillId    WHERE      (NOT ?1 OR drill = ?2)       AND (NOT ?3 OR action = ?4)    GROUP BY startDay    ORDER BY startDay DESC    LIMIT ?5    OFFSET ?6',
        mapper: (Map<String, Object?> row) => _AggregatedDrillReps(row['startDay'] as String, row['endDay'] as String, row['reps'] as int, row['accuracy'] as double?),
        arguments: [
          matchDrill ? 1 : 0,
          drill,
          matchAction ? 1 : 0,
          action,
          numWeeks,
          offset
        ]);
  }

  @override
  Future<List<_AggregatedDrillReps>> _weeklyDrillReps(
    bool matchDrill,
    String drill,
    bool matchAction,
    String action,
    int numWeeks,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT      DATE(startSeconds, \"unixepoch\", \"localtime\", \"weekday 0\", \"-6 days\") startDay,      DATE(startSeconds, \"unixepoch\", \"localtime\", \"weekday 0\") endDay,      IFNULL(SUM(reps), 0) reps,      (CAST(SUM(CASE WHEN Drills.tracking THEN Actions.good ELSE 0 END) AS DOUBLE) /       CAST(SUM(CASE WHEN Drills.tracking THEN Actions.reps ELSE 0 END) AS DOUBLE)) accuracy    FROM Drills    LEFT JOIN Actions ON Drills.id = Actions.drillId    WHERE      (NOT ?1 OR drill = ?2)      AND (NOT ?3 OR Actions.action = ?4)    GROUP BY startDay    ORDER BY startDay DESC    LIMIT ?5    OFFSET ?6',
        mapper: (Map<String, Object?> row) => _AggregatedDrillReps(row['startDay'] as String, row['endDay'] as String, row['reps'] as int, row['accuracy'] as double?),
        arguments: [
          matchDrill ? 1 : 0,
          drill,
          matchAction ? 1 : 0,
          action,
          numWeeks,
          offset
        ]);
  }

  @override
  Future<List<_AggregatedDrillReps>> _monthlyDrillReps(
    bool matchDrill,
    String drill,
    bool matchAction,
    String action,
    int numWeeks,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT      DATE(startSeconds, \"unixepoch\", \"localtime\", \"start of month\") startDay,      DATE(startSeconds, \"unixepoch\", \"localtime\", \"start of month\", \"+1 month\") endDay,      IFNULL(SUM(reps), 0) reps,      (CAST(SUM(CASE WHEN Drills.tracking THEN Actions.good ELSE 0 END) AS DOUBLE) /        CAST(SUM(CASE WHEN Drills.tracking THEN Actions.reps ELSE 0 END) AS DOUBLE)) accuracy    FROM Drills    LEFT JOIN Actions ON Drills.id = Actions.drillId    WHERE      (NOT ?1 OR drill = ?2)       AND (NOT ?3 OR action = ?4)    GROUP BY startDay    ORDER BY startDay DESC    LIMIT ?5    OFFSET ?6',
        mapper: (Map<String, Object?> row) => _AggregatedDrillReps(row['startDay'] as String, row['endDay'] as String, row['reps'] as int, row['accuracy'] as double?),
        arguments: [
          matchDrill ? 1 : 0,
          drill,
          matchAction ? 1 : 0,
          action,
          numWeeks,
          offset
        ]);
  }

  @override
  Future<List<AggregatedActionReps>> loadWeeklyActionReps(
    String drill,
    int numWeeks,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT      DATE(startSeconds, \"unixepoch\", \"localtime\", \"weekday 0\", \"-6 days\") startDayStr,      DATE(startSeconds, \"unixepoch\", \"localtime\", \"weekday 0\") endDayStr,      Actions.action,      IFNULL(SUM(reps), 0) reps,      (CAST(SUM(CASE WHEN Drills.tracking THEN Actions.good ELSE 0 END) AS DOUBLE) /        CAST(SUM(CASE WHEN Drills.tracking THEN Actions.reps ELSE 0 END) AS DOUBLE)) accuracy    FROM Drills    LEFT JOIN Actions ON Drills.id = Actions.drillId    WHERE      drill = ?1     GROUP BY startDayStr, Actions.action    ORDER BY startDayStr DESC, Actions.action    LIMIT ?2    OFFSET ?3',
        mapper: (Map<String, Object?> row) => AggregatedActionReps(row['startDayStr'] as String, row['endDayStr'] as String, row['action'] as String, row['reps'] as int, row['accuracy'] as double?),
        arguments: [drill, numWeeks, offset]);
  }
}
