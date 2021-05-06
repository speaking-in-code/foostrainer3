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

StoredAction _$StoredActionFromJson(Map<String, dynamic> json) {
  return StoredAction(
    id: json['id'] as int,
    drillId: json['drillId'] as int,
    action: json['action'] as String,
    reps: json['reps'] as int,
    good: json['good'] as int,
  );
}

Map<String, dynamic> _$StoredActionToJson(StoredAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'drillId': instance.drillId,
      'action': instance.action,
      'reps': instance.reps,
      'good': instance.good,
    };

DrillSummary _$DrillSummaryFromJson(Map<String, dynamic> json) {
  return DrillSummary(
    drill: json['drill'] == null
        ? null
        : StoredDrill.fromJson(json['drill'] as Map<String, dynamic>),
    reps: json['reps'] as int,
    good: json['good'] as int,
    actions: (json['actions'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k,
          e == null ? null : StoredAction.fromJson(e as Map<String, dynamic>)),
    ),
  );
}

Map<String, dynamic> _$DrillSummaryToJson(DrillSummary instance) =>
    <String, dynamic>{
      'drill': instance.drill,
      'reps': instance.reps,
      'good': instance.good,
      'actions': instance.actions,
    };
