import 'package:flutter/material.dart';

import 'log.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'play_button_widget.dart';
import 'practice_background.dart';
import 'practice_screen.dart';
import 'static_drills.dart';

final _log = Log.get('home_screen');

// Widget to select drill for practice.
class HomeScreen extends StatelessWidget {
  static const routeName = '/home';
  final StaticDrills staticDrills;

  HomeScreen({@required this.staticDrills});

  @override
  Widget build(BuildContext context) {
    _navToPracticeIfRunning(context);
    return Scaffold(
      appBar: MyAppBar(title: 'FoosTrainer').build(context),
      body: PlayButtonWidget(staticDrills: staticDrills),
      bottomNavigationBar: MyNavBar.forNormalNav(MyNavBarLocation.practice),
    );
  }

  void _navToPracticeIfRunning(BuildContext context) async {
    if (await PracticeBackground.running()) {
      _log.info('Audio running, navigating to practice screen.');
      Navigator.of(context, rootNavigator: true)
          .pushReplacementNamed(PracticeScreen.routeName);
    }
  }
}
