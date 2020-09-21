class DebugInfo {
  static const action = 'GetDebugInfo';
}

class DebugInfoResponse {
  static const _meanDelayMillis = 'meanDelayMillis';
  static const _stdDevDelayMillis = 'stdDevDelayMillis';
  double meanDelayMillis = 0;
  double stdDevDelayMillis = 0;

  DebugInfoResponse({this.meanDelayMillis, this.stdDevDelayMillis});

  static DebugInfoResponse fromWire(Map resp) {
    return DebugInfoResponse(
        meanDelayMillis: resp[_meanDelayMillis],
        stdDevDelayMillis: resp[_stdDevDelayMillis]);
  }

  Map toWire() {
    return {
      _meanDelayMillis: meanDelayMillis,
      _stdDevDelayMillis: stdDevDelayMillis,
    };
  }
}
