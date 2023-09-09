// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drill_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionData _$ActionDataFromJson(Map<String, dynamic> json) => ActionData(
      label: json['label'] as String,
      audioAsset: json['audioAsset'] as String,
    );

Map<String, dynamic> _$ActionDataToJson(ActionData instance) =>
    <String, dynamic>{
      'label': instance.label,
      'audioAsset': instance.audioAsset,
    };

DrillData _$DrillDataFromJson(Map<String, dynamic> json) => DrillData(
      name: json['name'] as String,
      type: json['type'] as String,
      possessionSeconds: json['possessionSeconds'] as int,
      actions: (json['actions'] as List<dynamic>)
          .map((e) => ActionData.fromJson(e as Map<String, dynamic>))
          .toList(),
      tempo: $enumDecodeNullable(_$TempoEnumMap, json['tempo']),
      signal: $enumDecodeNullable(_$SignalEnumMap, json['signal']),
      practiceMinutes: json['practiceMinutes'] as int?,
      tracking: json['tracking'] as bool?,
    );

Map<String, dynamic> _$DrillDataToJson(DrillData instance) => <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'possessionSeconds': instance.possessionSeconds,
      'actions': instance.actions,
      'tempo': _$TempoEnumMap[instance.tempo],
      'signal': _$SignalEnumMap[instance.signal],
      'practiceMinutes': instance.practiceMinutes,
      'tracking': instance.tracking,
    };

const _$TempoEnumMap = {
  Tempo.RANDOM: 'RANDOM',
  Tempo.FAST: 'FAST',
  Tempo.SLOW: 'SLOW',
};

const _$SignalEnumMap = {
  Signal.AUDIO: 'AUDIO',
  Signal.AUDIO_AND_FLASH: 'AUDIO_AND_FLASH',
};

DrillListData _$DrillListDataFromJson(Map<String, dynamic> json) =>
    DrillListData(
      drills: (json['drills'] as List<dynamic>?)
          ?.map((e) => DrillData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DrillListDataToJson(DrillListData instance) =>
    <String, dynamic>{
      'drills': instance.drills,
    };
