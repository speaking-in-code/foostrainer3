import 'package:flutter/material.dart';

import 'app_rater.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'play_button_widget.dart';
import 'practice_background.dart';
import 'practice_screen.dart';
import 'static_drills.dart';

final _log = Log.get('home_screen');

// Widget to select drill for practice.
class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  final StaticDrills staticDrills;
  final AppRater appRater;

  HomeScreen({required this.staticDrills, required this.appRater});

  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _navToPracticeIfRunning(context);
  }

  void _navToPracticeIfRunning(BuildContext context) async {
    if (await PracticeBackground.running()) {
      _log.info('Audio running, navigating to practice screen.');
      PracticeScreen.pushNamed(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'FoosTrainer', appRater: widget.appRater)
          .build(context),
      body: PlayButtonWidget(staticDrills: widget.staticDrills),
      bottomNavigationBar: MyNavBar.forNormalNav(MyNavBarLocation.practice),
    );
  }
}
