import 'package:flutter/material.dart';

import 'drill_chooser_screen.dart';
import 'drill_data.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'play_button_widget.dart';
import 'practice_config_screen.dart';
import 'static_drills.dart';

// Widget to select drill for practice.
class HomeScreen extends StatelessWidget {
  static const routeName = '/home';
  final StaticDrills staticDrills;

  HomeScreen({@required this.staticDrills});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'FoosTrainer').build(context),
      body: PlayButtonWidget(staticDrills: staticDrills),
      bottomNavigationBar: MyNavBar.forNormalNav(MyNavBarLocation.practice),
    );
  }
}
