import 'package:intl/intl.dart';

class PercentFormatter {
  static final _pctFormatter = NumberFormat.percentPattern()
    ..maximumFractionDigits = 0;

  static String format(num num) {
    return _pctFormatter.format(num);
  }

  static String formatAccuracy({int trackedReps, int trackedGood}) {
    if (trackedGood == null || trackedReps == null || trackedReps == 0) {
      return '--';
    }
    return format(trackedGood / trackedReps);
  }
}
