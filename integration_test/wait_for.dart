import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

extension WaitFor on WidgetTester {
  static const _delay = Duration(milliseconds: 50);

  Future<void> waitFor(Finder finder,
      {Duration timeout = const Duration(seconds: 30)}) async {
    final timer = Stopwatch()..start();
    while (timer.elapsed < timeout) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await Future.delayed(_delay);
    }
    if (finder.evaluate().isNotEmpty) {
      print('BEE waited for $finder and found it');
      return;
    }
    throw FlutterError(
        'The finder "$finder" (used in a call to "waitFor()") could not find any matching widgets.');
  }
}
