// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetTrackingRequest _$SetTrackingRequestFromJson(Map<String, dynamic> json) {
  return SetTrackingRequest(
    trackingResult:
        _$enumDecodeNullable(_$TrackingResultEnumMap, json['trackingResult']),
  );
}

Map<String, dynamic> _$SetTrackingRequestToJson(SetTrackingRequest instance) =>
    <String, dynamic>{
      'trackingResult': _$TrackingResultEnumMap[instance.trackingResult],
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

const _$TrackingResultEnumMap = {
  TrackingResult.GOOD: 'GOOD',
  TrackingResult.MISSED: 'MISSED',
  TrackingResult.SKIP: 'SKIP',
};
