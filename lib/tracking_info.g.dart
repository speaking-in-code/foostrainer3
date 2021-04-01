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

const _$TrackingResultEnumMap = {
  TrackingResult.GOOD: 'GOOD',
  TrackingResult.MISSED: 'MISSED',
  TrackingResult.SKIP: 'SKIP',
};
