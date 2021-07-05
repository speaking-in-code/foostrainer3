/// Data object describing debug info.
/// To regenerate json serialization:
///   flutter pub run build_runner build
import 'package:json_annotation/json_annotation.dart';

part 'debug_info.g.dart'; // Allows private access to generated code.

class DebugInfo {
  static const action = 'GetDebugInfo';
}

@JsonSerializable()
class DebugInfoResponse {
  double? meanDelayMillis = 0;
  double? stdDevDelayMillis = 0;

  DebugInfoResponse(
      {this.meanDelayMillis, this.stdDevDelayMillis});

  factory DebugInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$DebugInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DebugInfoResponseToJson(this);
}
