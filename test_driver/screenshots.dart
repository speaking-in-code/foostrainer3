import 'package:flutter_driver/driver_extension.dart';
import 'package:ft3/main.dart' as app;
import 'package:flutter/widgets.dart';

void main() {
  // Enable the flutter driver extension so that tests can control the app.
  enableFlutterDriverExtension();
  // Remove the debug logo, so screenshots look better.
  WidgetsApp.debugAllowBannerOverride = false;
  app.main();
}
