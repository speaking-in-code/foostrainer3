import 'package:flutter/material.dart';

import 'drill_data.dart';

// Displays a list of drills.
class DrillListScreen extends StatelessWidget {
  static const routeName = '/drillList';

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute settings and cast
    // them as ScreenArguments.
    final List<DrillData> drills = ModalRoute.of(context).settings.arguments;
    var children = List<Widget>();
    String type = drills[0]?.type ?? '';
    for (DrillData drill in drills) {
      children.add(Card(child: ListTile(title: Text(drill.name))));
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(type),
        ),
        body: ListView(key: key, children: children));
  }
}
