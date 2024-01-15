
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fbtl_screenshots/fbtl_screenshots.dart';

import 'app_starter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  //final _screenshots = FBTLScreenshots();
  //_screenshots.connect();

  testWidgets('Home Screen', (WidgetTester tester) async {
    await startFoosTrainer(tester);
    print('Home Screen test finished');
    //await _screenshots.takeScreenshot(tester, '01-home-screen');
  });
}

