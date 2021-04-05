// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'results_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultsInfo _$ResultsInfoFromJson(Map<String, dynamic> json) {
  return ResultsInfo(
    startSeconds: json['startSeconds'] as int,
    drill: json['drill'] as String,
    elapsedSeconds: json['elapsedSeconds'] as int,
    reps: json['reps'] as int,
    good: json['good'] as int,
  );
}

Map<String, dynamic> _$ResultsInfoToJson(ResultsInfo instance) =>
    <String, dynamic>{
      'startSeconds': instance.startSeconds,
      'drill': instance.drill,
      'elapsedSeconds': instance.elapsedSeconds,
      'reps': instance.reps,
      'good': instance.good,
    };
