// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'results_entities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoredDrill _$StoredDrillFromJson(Map<String, dynamic> json) {
  return StoredDrill(
    id: json['id'] as int,
    startSeconds: json['startSeconds'] as int,
    drill: json['drill'] as String,
    tracking: json['tracking'] as bool,
    elapsedSeconds: json['elapsedSeconds'] as int,
  );
}

Map<String, dynamic> _$StoredDrillToJson(StoredDrill instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startSeconds': instance.startSeconds,
      'drill': instance.drill,
      'tracking': instance.tracking,
      'elapsedSeconds': instance.elapsedSeconds,
    };

DrillSummary _$DrillSummaryFromJson(Map<String, dynamic> json) {
  return DrillSummary(
    drill: json['drill'] == null
        ? null
        : StoredDrill.fromJson(json['drill'] as Map<String, dynamic>),
    reps: json['reps'] as int,
    good: json['good'] as int,
    accuracy: (json['accuracy'] as num)?.toDouble(),
    actionReps: (json['actionReps'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
  );
}

Map<String, dynamic> _$DrillSummaryToJson(DrillSummary instance) =>
    <String, dynamic>{
      'drill': instance.drill,
      'reps': instance.reps,
      'good': instance.good,
      'accuracy': instance.accuracy,
      'actionReps': instance.actionReps,
    };
