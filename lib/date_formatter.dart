import 'package:intl/intl.dart';

class DateFormatter {
  static final _dayFormat = DateFormat.yMMMd();
  static final _dayTimeFormat = DateFormat.yMMMd().add_jm();

  static String formatDay(DateTime when) => _dayFormat.format(when);

  static String formatDayTime(DateTime when) => _dayTimeFormat.format(when);
}
