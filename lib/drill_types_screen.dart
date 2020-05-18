import 'package:flutter/material.dart';

import 'drill_list_screen.dart';
import 'static_drills.dart';

// Widget for list of drills types.
class DrillTypesScreen extends StatelessWidget {
  static const routeName = '/drill_types';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: StaticDrills.load(),
        builder: (context, AsyncSnapshot<StaticDrills> snapshot) {
          var children = List<Widget>();
          if (snapshot.data != null) {
            for (String type in snapshot.data.types) {
              children.add(Card(
                  child: ListTile(
                      title: Text(type),
                      onTap: () {
                        Navigator.pushNamed(context, DrillListScreen.routeName,
                            arguments: snapshot.data.getDrills(type));
                      })));
            }
          }
          return Scaffold(
              appBar: AppBar(title: Text('Drill Type')),
              body: ListView(key: key, children: children));
        });
  }
}
