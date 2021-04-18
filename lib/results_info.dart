import 'dart:convert';

/// Data object describing practice results.
/// To regenerate json serialization:
///   flutter pub run build_runner build
///
import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'results_info.g.dart';

@JsonSerializable()
@Entity(tableName: 'Drills')
class ResultsInfo {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final int startSeconds;
  final String drill;
  final bool tracking;
  int elapsedSeconds;

  ResultsInfo({
    this.id,
    this.startSeconds,
    this.drill,
    this.tracking,
    int elapsedSeconds,
  }) {
    this.elapsedSeconds = elapsedSeconds ?? 0;
  }

  factory ResultsInfo.newDrill({String drill, bool tracking}) {
    return ResultsInfo(
      startSeconds: (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      drill: drill,
      tracking: tracking,
    );
  }

  String encode() {
    return jsonEncode(_$ResultsInfoToJson(this));
  }

  factory ResultsInfo.decode(String json) {
    return _$ResultsInfoFromJson(jsonDecode(json));
  }

  factory ResultsInfo.fromJson(Map<String, dynamic> json) =>
      _$ResultsInfoFromJson(json);
}

@Entity(tableName: 'Actions', foreignKeys: [
  ForeignKey(
    childColumns: ['drillId'],
    parentColumns: ['id'],
    entity: ResultsInfo,
  )
])
class ResultsActionsInfo {
  @primaryKey
  final int id;

  final int drillId;
  final String action;
  int reps;
  // null means not counted
  int good;

  ResultsActionsInfo(
      {this.id, this.drillId, this.action, this.reps, this.good}) {
    reps = reps ?? 0;
  }
}
