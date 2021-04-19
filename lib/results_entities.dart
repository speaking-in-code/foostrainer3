import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Data object describing practice results.
/// To regenerate json serialization:
///   flutter pub run build_runner build
///
import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'results_entities.g.dart';

@JsonSerializable()
@Entity(tableName: 'Drills')
class StoredDrill {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final int startSeconds;
  final String drill;
  final bool tracking;
  int elapsedSeconds;

  StoredDrill({
    this.id,
    this.startSeconds,
    this.drill,
    this.tracking,
    int elapsedSeconds,
  }) {
    this.elapsedSeconds = elapsedSeconds ?? 0;
  }

  factory StoredDrill.newDrill({String drill, bool tracking}) {
    return StoredDrill(
      startSeconds: (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      drill: drill,
      tracking: tracking,
    );
  }

  String encode() {
    return jsonEncode(_$StoredDrillToJson(this));
  }

  factory StoredDrill.decode(String json) {
    return _$StoredDrillFromJson(jsonDecode(json));
  }

  factory StoredDrill.fromJson(Map<String, dynamic> json) =>
      _$StoredDrillFromJson(json);
}

@Entity(tableName: 'Actions', foreignKeys: [
  ForeignKey(
    childColumns: ['drillId'],
    parentColumns: ['id'],
    entity: StoredDrill,
  )
])
class StoredAction {
  @primaryKey
  final int id;

  final int drillId;
  final String action;
  final int reps;
  // null means not counted
  final int good;

  StoredAction({this.id, this.drillId, this.action, int reps, this.good})
      : this.reps = reps ?? 0;
}

/// Summary of results for a single drill.
class DrillSummary {
  final String drill;
  final int reps;
  final int elapsedSeconds;
  final int good; // nullable
  final double accuracy; // nullable
  final Map<String, int> actionReps; // sorted

  DrillSummary(
      {this.drill,
      this.reps,
      this.elapsedSeconds,
      this.good,
      this.accuracy,
      this.actionReps});
}

/// Summary of drill results by day.
class WeeklyDrillSummary extends Equatable {
  final DateTime startDay;
  final DateTime endDay;
  final int elapsedSeconds;
  final int reps;
  final double accuracy;

  WeeklyDrillSummary(this.startDay, this.endDay, this.elapsedSeconds, this.reps,
      this.accuracy);

  @override
  List<Object> get props => [startDay, endDay, elapsedSeconds, reps, accuracy];
}
