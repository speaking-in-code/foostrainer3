// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'results_db.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

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

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

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
        ? await sqfliteDatabaseFactory.getDatabasePath(name)
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
  _$ResultsDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  DrillsDao _drillsDaoInstance;

  ActionsDao _actionsDaoInstance;

  SummariesDao _summariesDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
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
            'CREATE TABLE IF NOT EXISTS `Drills` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `startSeconds` INTEGER, `drill` TEXT, `tracking` INTEGER, `elapsedSeconds` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Actions` (`id` INTEGER, `drillId` INTEGER, `action` TEXT, `reps` INTEGER, `good` INTEGER, FOREIGN KEY (`drillId`) REFERENCES `Drills` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');

        await database.execute(
            '''CREATE VIEW IF NOT EXISTS `_WeeklyDrillTime` AS SELECT NULL''');
        await database.execute(
            '''CREATE VIEW IF NOT EXISTS `_WeeklyDrillReps` AS SELECT NULL''');

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
  _$DrillsDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _resultsInfoInsertionAdapter = InsertionAdapter(
            database,
            'Drills',
            (ResultsInfo item) => <String, dynamic>{
                  'id': item.id,
                  'startSeconds': item.startSeconds,
                  'drill': item.drill,
                  'tracking':
                      item.tracking == null ? null : (item.tracking ? 1 : 0),
                  'elapsedSeconds': item.elapsedSeconds
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ResultsInfo> _resultsInfoInsertionAdapter;

  @override
  Future<ResultsInfo> findResults(int id) async {
    return _queryAdapter.query('SELECT * FROM Drills WHERE id = ?',
        arguments: <dynamic>[id],
        mapper: (Map<String, dynamic> row) => ResultsInfo(
            id: row['id'] as int,
            startSeconds: row['startSeconds'] as int,
            drill: row['drill'] as String,
            tracking:
                row['tracking'] == null ? null : (row['tracking'] as int) != 0,
            elapsedSeconds: row['elapsedSeconds'] as int));
  }

  @override
  Future<int> insertResults(ResultsInfo results) {
    return _resultsInfoInsertionAdapter.insertAndReturnId(
        results, OnConflictStrategy.replace);
  }
}

class _$ActionsDao extends ActionsDao {
  _$ActionsDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _resultsActionsInfoInsertionAdapter = InsertionAdapter(
            database,
            'Actions',
            (ResultsActionsInfo item) => <String, dynamic>{
                  'id': item.id,
                  'drillId': item.drillId,
                  'action': item.action,
                  'reps': item.reps,
                  'good': item.good
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ResultsActionsInfo>
      _resultsActionsInfoInsertionAdapter;

  @override
  Future<ResultsActionsInfo> findAction(int drillId, String action) async {
    return _queryAdapter.query(
        'SELECT * from Actions WHERE drillId = ? AND action = ?',
        arguments: <dynamic>[drillId, action],
        mapper: (Map<String, dynamic> row) => ResultsActionsInfo(
            id: row['id'] as int,
            drillId: row['drillId'] as int,
            action: row['action'] as String,
            reps: row['reps'] as int,
            good: row['good'] as int));
  }

  @override
  Future<List<ResultsActionsInfo>> findActions(int drillId) async {
    return _queryAdapter.queryList('SELECT * from Actions WHERE drillId = ?',
        arguments: <dynamic>[drillId],
        mapper: (Map<String, dynamic> row) => ResultsActionsInfo(
            id: row['id'] as int,
            drillId: row['drillId'] as int,
            action: row['action'] as String,
            reps: row['reps'] as int,
            good: row['good'] as int));
  }

  @override
  Future<int> insertAction(ResultsActionsInfo results) {
    return _resultsActionsInfoInsertionAdapter.insertAndReturnId(
        results, OnConflictStrategy.replace);
  }

  @override
  Future<void> incrementAction(int drillId, String action, bool good) async {
    if (database is sqflite.Transaction) {
      await super.incrementAction(drillId, action, good);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$ResultsDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.actionsDao
            .incrementAction(drillId, action, good);
      });
    }
  }
}

class _$SummariesDao extends SummariesDao {
  _$SummariesDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  @override
  Future<List<_WeeklyDrillTime>> _weeklyDrillTime(
      int endSeconds, int numWeeks) async {
    return _queryAdapter.queryList(
        'SELECT DATE(startSeconds, "unixepoch", "weekday 0", "-6 days") startDay, DATE(startSeconds, "unixepoch", "weekday 0") endDay, SUM(elapsedSeconds) elapsedSeconds FROM Drills WHERE startSeconds < ? GROUP BY startDay ORDER BY startDay DESC LIMIT ?',
        arguments: <dynamic>[endSeconds, numWeeks],
        mapper: (Map<String, dynamic> row) => _WeeklyDrillTime(
            row['startDay'] as String,
            row['endDay'] as String,
            row['elapsedSeconds'] as int));
  }

  @override
  Future<List<_WeeklyDrillReps>> _weeklyDrillReps(
      int endSeconds, int numWeeks) async {
    return _queryAdapter.queryList(
        'SELECT DATE(startSeconds, "unixepoch", "weekday 0", "-6 days") startDay, DATE(startSeconds, "unixepoch", "weekday 0") endDay, IFNULL(SUM(reps), 0) reps, CAST(SUM(IIF(Drills.tracking, Actions.good, 0)) AS DOUBLE) / CAST(SUM(IIF(drills.tracking, Actions.reps, 0)) AS DOUBLE) accuracy FROM Drills LEFT JOIN Actions ON Drills.id = Actions.drillId WHERE startSeconds < ? GROUP BY startDay ORDER BY startDay DESC LIMIT ?',
        arguments: <dynamic>[endSeconds, numWeeks],
        mapper: (Map<String, dynamic> row) => _WeeklyDrillReps(
            row['startDay'] as String,
            row['endDay'] as String,
            row['reps'] as int,
            row['accuracy'] as double));
  }
}
