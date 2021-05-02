import 'package:intl/intl.dart';

class DateFormatter {
  static final _format = DateFormat.yMMMd();

  static String format(DateTime when) => _format.format(when);
}
