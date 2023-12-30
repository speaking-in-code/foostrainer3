import 'package:flutter/material.dart';

import 'drill_chooser_screen.dart';
import 'drill_data.dart';
import 'static_drills.dart';

class PlayButtonWidget extends StatelessWidget {
  final StaticDrills staticDrills;
  final DrillData? drillData;

  PlayButtonWidget({required this.staticDrills, this.drillData});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ElevatedButton.icon(
      label: Text('Start Practice'),
      icon: Icon(Icons.play_arrow),
      onPressed: () => DrillChooserScreen.push(context, drillData),
    ));
  }
}
