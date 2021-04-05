import 'dart:convert';

/// Data object describing practice results.
/// To regenerate json serialization:
///   flutter pub run build_runner build
///
import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'results_info.g.dart';

@JsonSerializable()
@entity
class ResultsInfo {
  @primaryKey
  final int startSeconds;
  final String drill;
  int elapsedSeconds;
  int reps;
  // Good reps of -1 means disabled.
  int good;

  ResultsInfo({
    this.startSeconds,
    this.drill,
    int elapsedSeconds,
    int reps,
    int good,
  }) {
    this.elapsedSeconds = elapsedSeconds ?? 0;
    this.reps = reps ?? 0;
    this.good = good ?? -1;
  }

  factory ResultsInfo.newDrill({String drill, bool tracking}) {
    return ResultsInfo(
      startSeconds: (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      drill: drill,
      good: tracking ? 0 : -1,
    );
  }

  factory ResultsInfo.decode(String json) {
    return _$ResultsInfoFromJson(jsonDecode(json));
  }

  String encode() {
    return jsonEncode(_$ResultsInfoToJson(this));
  }

  factory ResultsInfo.fromJson(Map<String, dynamic> json) =>
      _$ResultsInfoFromJson(json);
}
