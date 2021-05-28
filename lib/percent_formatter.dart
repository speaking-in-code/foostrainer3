import 'package:intl/intl.dart';

class PercentFormatter {
  static const _notAvailable = '--';
  static final _pctFormatter = NumberFormat.percentPattern()
    ..maximumFractionDigits = 0;

  static String format(num fraction) {
    if (fraction == null) {
      return _notAvailable;
    }
    return _pctFormatter.format(fraction);
  }

  static String formatAccuracy({int trackedReps, int trackedGood}) {
    if (trackedGood == null || trackedReps == null || trackedReps == 0) {
      return _notAvailable;
    }
    return format(trackedGood / trackedReps);
  }
}
