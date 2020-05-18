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
    actions: (json['actions'] as List)
        ?.map((e) =>
            e == null ? null : ActionData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$DrillDataToJson(DrillData instance) => <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'actions': instance.actions,
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
