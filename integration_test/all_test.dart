import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'app_starter.dart';
import 'home_screen_test.dart';
import 'drill_test.dart';

void main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Allow background updates to be handled by the app.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  final appStarter = AppStarter.create(fakeDrillScreen: false);

  group('Home Screen', homeScreenTests(appStarter));
  group('Drills', drillTests(appStarter));
}
