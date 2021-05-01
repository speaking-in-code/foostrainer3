import 'package:intl/intl.dart';

class PercentFormatter {
  static final _pctFormatter = NumberFormat.percentPattern()
    ..maximumFractionDigits = 0;

  static String format(double num) {
    return _pctFormatter.format(num);
  }
}
