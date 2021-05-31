import 'package:flutter/material.dart';

import 'drill_chooser_screen.dart';
import 'drill_data.dart';
import 'practice_config_screen.dart';
import 'static_drills.dart';

class PlayButtonWidget extends StatelessWidget {
  final StaticDrills staticDrills;
  final DrillData drillData;

  PlayButtonWidget({@required this.staticDrills, this.drillData})
      : assert(staticDrills != null);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ElevatedButton.icon(
      label: Text('Start Practice'),
      icon: Icon(Icons.play_arrow),
      onPressed: () => _onStartPractice(context),
    ));
  }

  void _onStartPractice(BuildContext context) async {
    DrillData chosen = drillData;
    if (chosen == null) {
      chosen = await DrillChooserScreen.startDialog(context,
          staticDrills: staticDrills);
    }
    if (chosen != null) {
      PracticeConfigScreen.navigate(context, chosen);
    }
  }
}
