import 'package:flutter/material.dart';

import 'drill_data.dart';
import 'practice_config_screen.dart';
import 'progress_screen.dart';

class DrillActionButtonsWidget extends StatelessWidget {
  final DrillData drillData;

  DrillActionButtonsWidget({required this.drillData});

  Widget build(BuildContext context) {
    return ButtonBar(children: [
      OutlinedButton.icon(
        icon: Icon(Icons.show_chart),
        label: Text('Progress'),
        onPressed: () => _onProgressClick(context),
      ),
      ElevatedButton.icon(
        icon: Icon(Icons.play_arrow),
        label: Text('Practice'),
        onPressed: () => _onPlayPressed(context),
      ),
    ]);
  }

  void _onProgressClick(BuildContext context) {
    ProgressScreen.navigate(context, drillData);
  }

  void _onPlayPressed(BuildContext context) {
    PracticeConfigScreen.navigate(context, drillData);
  }
}
