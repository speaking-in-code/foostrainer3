import 'package:flutter/material.dart';

import 'drill_chooser_screen.dart';
import 'drill_data.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'practice_config_screen.dart';
import 'static_drills.dart';

// Widget to select drill for practice.
class DrillTypesScreen extends StatelessWidget {
  static const routeName = '/drillTypes';
  final StaticDrills staticDrills;

  DrillTypesScreen({@required this.staticDrills});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'FoosTrainer').build(context),
      body: _playButton(context),
      bottomNavigationBar: MyNavBar(location: MyNavBarLocation.practice),
    );
  }

  Widget _playButton(BuildContext context) {
    return Center(
        child: ElevatedButton.icon(
      label: Text('Start Practice'),
      icon: Icon(Icons.play_arrow),
      onPressed: () => _onStartPractice(context),
    ));
  }

  void _onStartPractice(BuildContext context) async {
    DrillData chosen = await DrillChooserScreen.startDialog(context,
        staticDrills: staticDrills);
    if (chosen != null) {
      PracticeConfigScreen.navigate(context, chosen);
    }
  }
}
