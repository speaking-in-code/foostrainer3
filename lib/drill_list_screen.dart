import 'package:flutter/material.dart';

import 'drill_data.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'practice_config_screen.dart';

// Displays a list of drills.
class DrillListScreen extends StatelessWidget {
  static const routeName = '/drillList';

  static void navigate(BuildContext context, List<DrillData> drills) {
    Navigator.pushNamed(context, routeName, arguments: drills);
  }

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute settings and cast
    // them as ScreenArguments.
    final List<DrillData> drills = ModalRoute.of(context).settings.arguments;
    List<Widget> children = [];
    String type = drills[0]?.type ?? '';
    for (DrillData drill in drills) {
      children.add(Card(
          child: ListTile(
              title: Text(drill.name),
              onTap: () => PracticeConfigScreen.navigate(context, drill))));
    }
    return Scaffold(
      appBar: MyAppBar(title: type).build(context),
      body: ListView(key: key, children: children),
    );
  }
}
