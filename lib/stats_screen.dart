import 'package:flutter/material.dart';

import 'drill_data.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'results_db.dart';
import 'static_drills.dart';
import 'weekly_chart_widget.dart';

class StatsScreen extends StatelessWidget {
  static const routeName = '/stats';

  static void navigate(BuildContext context) {
    Navigator.pushNamed(context, routeName);
  }

  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;

  StatsScreen({this.staticDrills, this.resultsDb});

  @override
  Widget build(BuildContext context) {
    String title = 'Stats';
    return Scaffold(
      appBar: MyAppBar(title: title).build(context),
      body: _buildBody(context),
      bottomNavigationBar: MyNavBar(location: MyNavBarLocation.stats),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: WeeklyChartWidget(
        staticDrills: staticDrills,
        resultsDb: resultsDb,
      ),
    );
  }
}
