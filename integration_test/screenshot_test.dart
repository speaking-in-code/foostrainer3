
import 'package:flutter_test/flutter_test.dart';
import 'package:fbtl_screenshots/fbtl_screenshots.dart';

import 'app_starter.dart';

void main() {
  //final _screenshots = FBTLScreenshots();
  //_screenshots.connect();

  testWidgets('Home Screen', (WidgetTester tester) async {
    await startFoosTrainer(tester);
    //await _screenshots.takeScreenshot(tester, '01-home-screen');
  });
}

