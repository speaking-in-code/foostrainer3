// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'results_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultsInfo _$ResultsInfoFromJson(Map<String, dynamic> json) {
  return ResultsInfo(
    id: json['id'] as int,
    startSeconds: json['startSeconds'] as int,
    drill: json['drill'] as String,
    tracking: json['tracking'] as bool,
    elapsedSeconds: json['elapsedSeconds'] as int,
  );
}

Map<String, dynamic> _$ResultsInfoToJson(ResultsInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startSeconds': instance.startSeconds,
      'drill': instance.drill,
      'tracking': instance.tracking,
      'elapsedSeconds': instance.elapsedSeconds,
    };
