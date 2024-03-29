import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Data object describing practice results.
/// To regenerate json serialization:
///   flutter pub run build_runner build
///
import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'results_entities.g.dart';

@JsonSerializable()
@Entity(tableName: 'Drills')
class StoredDrill {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final int startSeconds;
  final String drill;
  final bool tracking;
  final int elapsedSeconds;

  DateTime get startTime =>
      DateTime.fromMillisecondsSinceEpoch(startSeconds * 1000);
  Duration get elapsed => Duration(seconds: elapsedSeconds);

  StoredDrill({
    this.id,
    required this.startSeconds,
    required this.drill,
    required this.tracking,
    required this.elapsedSeconds,
  }) : assert(drill.contains(':'), 'Stored drills must have format type:name');

  StoredDrill copyWith({int? id, int? elapsedSeconds}) {
    return StoredDrill(
        id: id ?? this.id,
        startSeconds: startSeconds,
        drill: drill,
        tracking: tracking,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds);
  }

  factory StoredDrill.newDrill(
      {required String drill, required bool tracking}) {
    return StoredDrill(
      startSeconds: (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      drill: drill,
      tracking: tracking,
      elapsedSeconds: 0,
    );
  }

  String encode() {
    return jsonEncode(toJson());
  }

  Map<String, dynamic> toJson() => _$StoredDrillToJson(this);

  factory StoredDrill.decode(String json) {
    return _$StoredDrillFromJson(jsonDecode(json));
  }

  factory StoredDrill.fromJson(Map<String, dynamic> json) =>
      _$StoredDrillFromJson(json);
}

@JsonSerializable()
@Entity(tableName: 'Actions', foreignKeys: [
  ForeignKey(
    childColumns: ['drillId'],
    parentColumns: ['id'],
    entity: StoredDrill,
  )
])
class StoredAction {
  @primaryKey
  final int? id;

  final int drillId;
  final String action;
  final int reps;
  // null means not counted
  final int? good;

  double? get accuracy => _computeAccuracy(good, reps);

  StoredAction(
      {this.id,
      required this.drillId,
      required this.action,
      int? reps,
      this.good})
      : this.reps = reps ?? 0;

  Map<String, dynamic> toJson() => _$StoredActionToJson(this);

  factory StoredAction.fromJson(Map<String, dynamic> json) =>
      _$StoredActionFromJson(json);
}

double? _computeAccuracy(int? good, int reps) {
  return (good == null || reps == 0) ? null : good / reps;
}

/// Summary of results for a single drill.
@JsonSerializable()
class DrillSummary {
  final StoredDrill drill;
  final int reps;
  final int? good; // nullable
  final Map<String, StoredAction> actions;

  DrillSummary(
      {required this.drill,
      required this.reps,
      this.good,
      required this.actions});

  double? get accuracy => _computeAccuracy(good, reps);

  DrillSummary copyWith({StoredDrill? drill, int? reps, int? good}) {
    return DrillSummary(
        drill: drill ?? this.drill,
        reps: reps ?? this.reps,
        good: good ?? this.good,
        actions: actions);
  }

  String encode() {
    return jsonEncode(_$DrillSummaryToJson(this));
  }

  factory DrillSummary.decode(String json) {
    return _$DrillSummaryFromJson(jsonDecode(json));
  }

  factory DrillSummary.fromJson(Map<String, dynamic> json) =>
      _$DrillSummaryFromJson(json);

  @override
  String toString() => encode();
}

/// Summary of drill results by day.
class AggregatedDrillSummary extends Equatable {
  final DateTime startDay;
  final DateTime endDay;
  final int elapsedSeconds;
  final int reps;
  final double? accuracy;

  // End of day is tricky during the fall time change, adding a day leaves
  // the hour at 23:00:00!
  AggregatedDrillSummary(@required this.startDay, @required DateTime endDay,
      @required this.elapsedSeconds, @required this.reps, this.accuracy)
      : endDay = DateTime(endDay.year, endDay.month, endDay.day, 24, 0, 0);

  @override
  List<Object?> get props => [startDay, endDay, elapsedSeconds, reps, accuracy];
}
