import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'home_screen_test.dart';

void main() {
  // IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('home screen', homeScreenTests);
}
