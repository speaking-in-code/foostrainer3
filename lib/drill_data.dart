import 'dart:convert';

/// Data object describing a drill.
/// To regenerate json serialization:
///   flutter pub run build_runner build
import 'package:json_annotation/json_annotation.dart';

part 'drill_data.g.dart'; // Allows private access to generated code.

// A single action, e.g. "Long", "Middle".
@JsonSerializable()
class ActionData {
  ActionData({required this.label, required this.audioAsset});

  String label;
  String audioAsset;
  factory ActionData.fromJson(Map<String, dynamic> json) =>
      _$ActionDataFromJson(json);
  Map<String, dynamic> toJson() => _$ActionDataToJson(this);
}

// Delay from ready to action.
enum Tempo {
  RANDOM,
  FAST,
  SLOW,
}

// Signal for action.
enum Signal {
  AUDIO,
  AUDIO_AND_FLASH,
}

// A set of actions with a name make up a drill.
// TODO: split into two types
// - static drill configuration
// - per-practice session configuration
@JsonSerializable()
class DrillData {
  String name;
  String type;
  int possessionSeconds;
  List<ActionData> actions;
  Tempo? tempo;
  Signal? signal;
  int? practiceMinutes;
  bool? tracking;

  DrillData({
    required this.name,
    required this.type,
    required this.possessionSeconds,
    required this.actions,
    this.tempo,
    this.signal,
    this.practiceMinutes,
    this.tracking,
  });

  DrillData copy() => copyWith();

  DrillData copyWith(
      {String? name,
      String? type,
      int? possessionSeconds,
      List<ActionData>? actions,
      Tempo? tempo,
      Signal? signal,
      int? practiceMinutes,
      bool? tracking}) {
    return DrillData(
        name: name ?? this.name,
        type: type ?? this.type,
        possessionSeconds: possessionSeconds ?? this.possessionSeconds,
        actions: actions ?? List.from(this.actions),
        tempo: tempo ?? this.tempo,
        signal: signal ?? this.signal,
        practiceMinutes: practiceMinutes ?? this.practiceMinutes,
        tracking: tracking ?? this.tracking);
  }

  String get fullName => '$type:$name';

  String get displayName => '$type: $name';

  factory DrillData.decode(String json) =>
      _$DrillDataFromJson(jsonDecode(json));
  factory DrillData.fromJson(Map<String, dynamic> json) =>
      _$DrillDataFromJson(json);
  Map<String, dynamic> toJson() => _$DrillDataToJson(this);
  String encode() => jsonEncode(_$DrillDataToJson(this));
}

@JsonSerializable()
class DrillListData {
  DrillListData({List<DrillData>? drills}) : drills = drills ?? [];

  List<DrillData> drills;

  factory DrillListData.decode(String json) =>
      _$DrillListDataFromJson(jsonDecode(json));
  String encode() => jsonEncode(_$DrillListDataToJson(this));
  Map<String, dynamic> toJson() => _$DrillListDataToJson(this);
}
