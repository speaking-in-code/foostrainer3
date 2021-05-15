import 'package:flutter/material.dart';

import 'drill_data.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'results_db.dart';
import 'static_drills.dart';

class DrillStatsScreen extends StatelessWidget {
  static const routeName = '/drillStats';

  static void navigate(BuildContext context, DrillData drillData) {
    Navigator.pushNamed(context, routeName, arguments: drillData);
  }

  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;

  DrillStatsScreen({this.staticDrills, this.resultsDb});

  @override
  Widget build(BuildContext context) {
    DrillData drillData = ModalRoute.of(context).settings.arguments;
    final title = 'Stats: ${drillData.name}';
    return Scaffold(
      appBar: MyAppBar(title: title).build(context),
      body: DrillChartsWidget(
          staticDrills: staticDrills,
          resultsDb: resultsDb,
          drillData: drillData),
      bottomNavigationBar: MyNavBar(MyNavBarLocation.STATS),
    );
  }
}
