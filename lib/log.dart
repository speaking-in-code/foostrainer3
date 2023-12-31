// Handles logging for foostrainer.

import 'package:logging/logging.dart';

class Log {
  static bool _initialized = false;

  static Logger get(String loggerName) {
    if (!_initialized) {
      Logger.root.onRecord.listen(_onRecord);
      _initialized = true;
    }
    return Logger(loggerName);
  }

  static void _onRecord(LogRecord record) {
    print(
        '${record.level.name}: ${record.time}: ${record.loggerName} ${record.message}');
  }
}
