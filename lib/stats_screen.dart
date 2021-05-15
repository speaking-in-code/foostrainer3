import 'package:flutter/material.dart';

import 'drill_data.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'results_db.dart';
import 'static_drills.dart';
import 'weekly_chart_widget.dart';

class StatsScreen extends StatelessWidget {
  static const routeName = '/stats';

  static void navigate(BuildContext context, DrillData drillData) {
    Navigator.pushNamed(context, routeName, arguments: drillData);
  }

  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;

  StatsScreen({this.staticDrills, this.resultsDb});

  @override
  Widget build(BuildContext context) {
    DrillData drillData = ModalRoute.of(context).settings.arguments;
    String title =
        (drillData?.name != null ? 'Stats: ${drillData.name}' : 'Stats');
    return Scaffold(
      appBar: MyAppBar(title: title).build(context),
      body: WeeklyChartWidget(
          staticDrills: staticDrills,
          resultsDb: resultsDb,
          drillData: drillData),
      bottomNavigationBar: MyNavBar(MyNavBarLocation.STATS),
    );
  }
}
