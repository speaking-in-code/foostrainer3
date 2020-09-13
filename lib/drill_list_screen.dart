import 'package:flutter/material.dart';

import 'drill_data.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'practice_background.dart';
import 'practice_screen.dart';
import 'screenshot_data.dart';

// Displays a list of drills.
class DrillListScreen extends StatelessWidget {
  static final _log = Log.get('DrillListScreen');
  static const routeName = '/drillList';

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute settings and cast
    // them as ScreenArguments.
    final List<DrillData> drills = ModalRoute.of(context).settings.arguments;
    var children = List<Widget>();
    String type = drills[0]?.type ?? '';
    for (DrillData drill in drills) {
      children.add(Card(
          child: ListTile(
              title: Text(drill.name),
              onTap: () => _startDrill(context, drill))));
    }
    return Scaffold(
        appBar: MyAppBar(title: type).build(context),
        body: ListView(key: key, children: children));
  }

  void _startDrill(BuildContext context, DrillData drill) {
    // Workaround for https://github.com/flutter/flutter/issues/35521, since
    // triggering native UI tends to trigger that bug.
    _log.info('Starting drill ${drill.name}');
    if (ScreenshotData.progress == null) {
      // Normal flow.
      PracticeBackground.startPractice(drill);
    }
    Navigator.pushNamed(context, PracticeScreen.routeName, arguments: drill);
  }
}
