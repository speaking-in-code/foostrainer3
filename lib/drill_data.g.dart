// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drill_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionData _$ActionDataFromJson(Map<String, dynamic> json) {
  return ActionData(
    label: json['label'] as String,
    audioAsset: json['audioAsset'] as String,
  );
}

Map<String, dynamic> _$ActionDataToJson(ActionData instance) =>
    <String, dynamic>{
      'label': instance.label,
      'audioAsset': instance.audioAsset,
    };

DrillData _$DrillDataFromJson(Map<String, dynamic> json) {
  return DrillData(
    name: json['name'] as String,
    type: json['type'] as String,
    possessionSeconds: json['possessionSeconds'] as int,
    tempo: _$enumDecodeNullable(_$TempoEnumMap, json['tempo']),
    signal: _$enumDecodeNullable(_$SignalEnumMap, json['signal']),
    practiceMinutes: json['practiceMinutes'] as int,
    tracking: json['tracking'] as bool,
    actions: (json['actions'] as List)
        ?.map((e) =>
            e == null ? null : ActionData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$DrillDataToJson(DrillData instance) => <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'possessionSeconds': instance.possessionSeconds,
      'tempo': _$TempoEnumMap[instance.tempo],
      'signal': _$SignalEnumMap[instance.signal],
      'practiceMinutes': instance.practiceMinutes,
      'tracking': instance.tracking,
      'actions': instance.actions,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$TempoEnumMap = {
  Tempo.RANDOM: 'RANDOM',
  Tempo.FAST: 'FAST',
  Tempo.SLOW: 'SLOW',
};

const _$SignalEnumMap = {
  Signal.AUDIO: 'AUDIO',
  Signal.AUDIO_AND_FLASH: 'AUDIO_AND_FLASH',
};

DrillListData _$DrillListDataFromJson(Map<String, dynamic> json) {
  return DrillListData(
    drills: (json['drills'] as List)
        ?.map((e) =>
            e == null ? null : DrillData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$DrillListDataToJson(DrillListData instance) =>
    <String, dynamic>{
      'drills': instance.drills,
    };
