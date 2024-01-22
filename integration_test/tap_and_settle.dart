
import 'package:flutter_test/flutter_test.dart';

extension TapAndSettle on WidgetTester {
  /// Finds the widget, taps it, and waits for the app to settle.
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }
}