import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'results_info.dart';

part 'results_db.g.dart';

@dao
abstract class ResultsInfoDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertResults(ResultsInfo results);

  @Query('SELECT * FROM ResultsInfo WHERE startSeconds = :startSeconds')
  Future<ResultsInfo> findResultsById(int startSeconds);

  @Query('SELECT * FROM ResultsInfo ORDER BY startSeconds DESC LIMIT 1')
  Future<ResultsInfo> findLastResults();
}

@Database(version: 1, entities: [ResultsInfo])
abstract class ResultsDatabase extends FloorDatabase {
  ResultsInfoDao get resultsInfoDao;
}
