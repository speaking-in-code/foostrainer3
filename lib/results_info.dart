/// Data object describing practice results.
/// To regenerate json serialization:
///   flutter pub run build_runner build
///
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'results_info.g.dart';

@JsonSerializable()
class ResultsInfo {
  static const prefsKey = 'ResultsInfo';

  ResultsInfo();

  String drill = '';
  int elapsedSeconds = 0;
  int reps = 0;
  int good; // null means not tracked.

  factory ResultsInfo.decode(String json) {
    return _$ResultsInfoFromJson(jsonDecode(json));
  }

  String encode() {
    return jsonEncode(_$ResultsInfoToJson(this));
  }
}
