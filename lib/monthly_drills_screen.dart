import 'package:flutter/material.dart';

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

  MonthlyDrillsScreen({required this.resultsDb, required this.staticDrills});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'History').build(context),
      body:
          MonthlyDrillsWidget(resultsDb: resultsDb, staticDrills: staticDrills),
      bottomNavigationBar: MyNavBar.forNormalNav(MyNavBarLocation.monthly),
    );
  }
}
