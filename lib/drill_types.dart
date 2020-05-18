import 'package:flutter/material.dart';
import 'package:ft3/static_drills.dart';

// Widget for list of drills types.
class DrillTypes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: StaticDrills.load(),
      builder: (context, AsyncSnapshot<StaticDrills> snapshot) {
        var children = List<Widget>();
        if (snapshot.data != null) {
          for (String type in snapshot.data.types) {
            children.add(Card(child: ListTile(title: Text(type))));
          }
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Drill Type')
          ),
          body: ListView(key: key, children: children)
        );
      }
    );
  }
}