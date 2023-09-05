/// Data object describing progress tracking info.

enum TrackingResult {
  GOOD,
  MISSED,
  SKIP,
}

class SetTrackingRequest {
  static const action = 'SetTrackingResult';
  static const result = 'result';
}
