import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'app_starter.dart';
import 'home_screen_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final appStarter = AppStarter();

  group('home screen', homeScreenTests(appStarter));
}
