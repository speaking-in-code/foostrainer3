import 'package:flutter/material.dart';

import 'drill_list_screen.dart';
import 'my_app_bar.dart';
import 'static_drills.dart';

// Widget for list of drills types.
class DrillTypesScreen extends StatelessWidget {
  static const routeName = '/drillTypes';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: StaticDrills.load(),
        builder: (context, AsyncSnapshot<StaticDrills> snapshot) {
          if (!snapshot.hasData) {
            return Scaffold();
          }
          StaticDrills drills = snapshot.requireData;
          List<Widget> children = [];
          for (String type in drills.types) {
            children.add(Card(
                child: ListTile(
                    title: Text(type),
                    onTap: () {
                      Navigator.pushNamed(context, DrillListScreen.routeName,
                          arguments: drills.getDrills(type));
                    })));
          }
          return Scaffold(
              appBar: MyAppBar(title: 'Drill Type').build(context),
              body: ListView(key: key, children: children));
        });
  }
}
