import 'package:sprintf/sprintf.dart';

class DurationFormatter {
  static const zero = '00:00:00';

  static String format(Duration elapsed) {
    int seconds = elapsed.inSeconds % 60;
    int minutes = elapsed.inMinutes % 60;
    int hours = elapsed.inHours;
    return sprintf('%02d:%02d:%02d', [hours, minutes, seconds]);
  }
}
