import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'drill_data.dart';
import 'practice_background.dart';
import 'practice_screen.dart';

// Displays a list of drills.
class DrillListScreen extends StatelessWidget {
  static final log = Logger();
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
        appBar: AppBar(
          title: Text(type),
        ),
        body: ListView(key: key, children: children));
  }

  void _startDrill(BuildContext context, DrillData drill) {
    PracticeBackground.startPractice(drill);
    Navigator.pushNamed(context, PracticeScreen.routeName, arguments: drill);
  }
}
