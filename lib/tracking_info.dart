/// Data object describing progress tracking info.
/// To regenerate json serialization:
///   flutter pub run build_runner build
import 'package:json_annotation/json_annotation.dart';

part 'tracking_info.g.dart'; // Allows private access to generated code.

enum TrackingResult {
  GOOD,
  MISSED,
  SKIP,
}

@JsonSerializable()
class SetTrackingRequest {
  static const action = 'SetTrackingResult';

  TrackingResult trackingResult;

  SetTrackingRequest({this.trackingResult});

  factory SetTrackingRequest.fromJson(Map<String, dynamic> json) =>
      _$SetTrackingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetTrackingRequestToJson(this);
}
