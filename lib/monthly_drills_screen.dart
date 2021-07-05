import 'package:flutter/material.dart';

import 'app_rater.dart';
import 'monthly_drills_widget.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'results_db.dart';
import 'static_drills.dart';

class MonthlyDrillsScreen extends StatelessWidget {
  static const routeName = '/monthly';

  static void navigate(BuildContext context) =>
      Navigator.pushNamed(context, routeName);

  final ResultsDatabase resultsDb;
  final StaticDrills staticDrills;
  final AppRater appRater;

  MonthlyDrillsScreen(
      {required this.resultsDb,
      required this.staticDrills,
      required this.appRater});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'History', appRater: appRater).build(context),
      body:
          MonthlyDrillsWidget(resultsDb: resultsDb, staticDrills: staticDrills),
      bottomNavigationBar: MyNavBar.forNormalNav(MyNavBarLocation.monthly),
    );
  }
}
