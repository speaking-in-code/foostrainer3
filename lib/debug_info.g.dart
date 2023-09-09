// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debug_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebugInfoResponse _$DebugInfoResponseFromJson(Map<String, dynamic> json) =>
    DebugInfoResponse(
      meanDelayMillis: (json['meanDelayMillis'] as num?)?.toDouble(),
      stdDevDelayMillis: (json['stdDevDelayMillis'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$DebugInfoResponseToJson(DebugInfoResponse instance) =>
    <String, dynamic>{
      'meanDelayMillis': instance.meanDelayMillis,
      'stdDevDelayMillis': instance.stdDevDelayMillis,
    };
