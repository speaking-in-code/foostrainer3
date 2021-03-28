/// Data object describing a drill.
/// To regenerate json serialization:
///   flutter pub run build_runner build
import 'package:json_annotation/json_annotation.dart';

part 'drill_data.g.dart'; // Allows private access to generated code.

// A single action, e.g. "Long", "Middle".
@JsonSerializable()
class ActionData {
  ActionData({this.label, this.audioAsset});

  String? label;
  String? audioAsset;
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

enum Tracking {
  ACCURACY_DISABLED,
  ACCURACY_ENABLED,
}

// A set of actions with a name make up a drill.
@JsonSerializable()
class DrillData {
  DrillData(
      {this.name,
      this.type,
      this.possessionSeconds,
      this.tempo,
      this.signal,
      this.practiceMinutes,
      this.tracking,
      List<ActionData>? actions})
      : actions = (actions ?? []);

  String? name;
  String? type;
  int? possessionSeconds;
  Tempo? tempo;
  Signal? signal;
  int? practiceMinutes;
  Tracking? tracking;
  List<ActionData> actions;

  factory DrillData.fromJson(Map<String, dynamic> json) =>
      _$DrillDataFromJson(json);
  Map<String, dynamic> toJson() => _$DrillDataToJson(this);
}

@JsonSerializable()
class DrillListData {
  DrillListData({List<DrillData>? drills}) : drills = drills ?? [];

  List<DrillData> drills;

  factory DrillListData.fromJson(Map<String, dynamic> json) =>
      _$DrillListDataFromJson(json);
  Map<String, dynamic> toJson() => _$DrillListDataToJson(this);
}
