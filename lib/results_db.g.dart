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

  ResultsInfoDao _resultsInfoDaoInstance;

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
            'CREATE TABLE IF NOT EXISTS `ResultsInfo` (`startSeconds` INTEGER, `drill` TEXT, `elapsedSeconds` INTEGER, `reps` INTEGER, `good` INTEGER, PRIMARY KEY (`startSeconds`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ResultsInfoDao get resultsInfoDao {
    return _resultsInfoDaoInstance ??=
        _$ResultsInfoDao(database, changeListener);
  }
}

class _$ResultsInfoDao extends ResultsInfoDao {
  _$ResultsInfoDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _resultsInfoInsertionAdapter = InsertionAdapter(
            database,
            'ResultsInfo',
            (ResultsInfo item) => <String, dynamic>{
                  'startSeconds': item.startSeconds,
                  'drill': item.drill,
                  'elapsedSeconds': item.elapsedSeconds,
                  'reps': item.reps,
                  'good': item.good
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ResultsInfo> _resultsInfoInsertionAdapter;

  @override
  Future<ResultsInfo> findResultsById(int startSeconds) async {
    return _queryAdapter.query(
        'SELECT * FROM ResultsInfo WHERE startSeconds = ?',
        arguments: <dynamic>[startSeconds],
        mapper: (Map<String, dynamic> row) => ResultsInfo(
            startSeconds: row['startSeconds'] as int,
            drill: row['drill'] as String,
            elapsedSeconds: row['elapsedSeconds'] as int,
            reps: row['reps'] as int,
            good: row['good'] as int));
  }

  @override
  Future<ResultsInfo> findLastResults() async {
    return _queryAdapter.query(
        'SELECT * FROM ResultsInfo ORDER BY startSeconds DESC LIMIT 1',
        mapper: (Map<String, dynamic> row) => ResultsInfo(
            startSeconds: row['startSeconds'] as int,
            drill: row['drill'] as String,
            elapsedSeconds: row['elapsedSeconds'] as int,
            reps: row['reps'] as int,
            good: row['good'] as int));
  }

  @override
  Future<void> insertResults(ResultsInfo results) async {
    await _resultsInfoInsertionAdapter.insert(
        results, OnConflictStrategy.replace);
  }
}
