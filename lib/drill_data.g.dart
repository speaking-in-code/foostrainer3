// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drill_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionData _$ActionDataFromJson(Map<String, dynamic> json) {
  return ActionData(
    label: json['label'] as String?,
    audioAsset: json['audioAsset'] as String?,
  );
}

Map<String, dynamic> _$ActionDataToJson(ActionData instance) =>
    <String, dynamic>{
      'label': instance.label,
      'audioAsset': instance.audioAsset,
    };

DrillData _$DrillDataFromJson(Map<String, dynamic> json) {
  return DrillData(
    name: json['name'] as String?,
    type: json['type'] as String?,
    possessionSeconds: json['possessionSeconds'] as int?,
    tempo: _$enumDecodeNullable(_$TempoEnumMap, json['tempo']),
    signal: _$enumDecodeNullable(_$SignalEnumMap, json['signal']),
    practiceMinutes: json['practiceMinutes'] as int?,
    tracking: _$enumDecodeNullable(_$TrackingEnumMap, json['tracking']),
    actions: (json['actions'] as List<dynamic>?)
        ?.map((e) => ActionData.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$DrillDataToJson(DrillData instance) => <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'possessionSeconds': instance.possessionSeconds,
      'tempo': _$TempoEnumMap[instance.tempo],
      'signal': _$SignalEnumMap[instance.signal],
      'practiceMinutes': instance.practiceMinutes,
      'tracking': _$TrackingEnumMap[instance.tracking],
      'actions': instance.actions,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
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

const _$TrackingEnumMap = {
  Tracking.ACCURACY_DISABLED: 'ACCURACY_DISABLED',
  Tracking.ACCURACY_ENABLED: 'ACCURACY_ENABLED',
};

DrillListData _$DrillListDataFromJson(Map<String, dynamic> json) {
  return DrillListData(
    drills: (json['drills'] as List<dynamic>?)
        ?.map((e) => DrillData.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$DrillListDataToJson(DrillListData instance) =>
    <String, dynamic>{
      'drills': instance.drills,
    };
