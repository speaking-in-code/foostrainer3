import 'package:flutter_driver/driver_extension.dart';
import 'package:ft3/main.dart' as app;
import 'package:flutter/widgets.dart';

import 'package:ft3/practice_background.dart';
import 'package:ft3/screenshot_data.dart';
import 'package:ft3/static_drills.dart';

void main() async {
  // Enable the flutter driver extension so that tests can control the app.
  enableFlutterDriverExtension();
  // Remove the debug logo, so screenshots look better.
  WidgetsApp.debugAllowBannerOverride = false;
  // Override the screenshot so that it looks good, and also works around
  // https://github.com/flutter/flutter/issues/35521 which sometimes triggers.
  var rollover;
  var drills = await StaticDrills.load();
  for (var drill in drills.getDrills('Rollover')) {
    if (drill.name == 'Up/Down/Middle') {
      rollover = drill;
      break;
    }
  }
  if (rollover == null) {
    throw Exception('Could not find rollover drill for screenshot');
  }
  ScreenshotData.progress = PracticeProgress(
      drill: rollover,
      state: PracticeState.playing,
      action: 'Wait',
      shotCount: 48,
      elapsed: '00:12:08');

  app.main();
}
