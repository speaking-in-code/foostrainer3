import 'package:flutter/material.dart';

import 'drill_charts_widget.dart';
import 'drill_data.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'results_db.dart';
import 'static_drills.dart';
import 'weekly_chart_widget.dart';

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
      body: _buildBody(context, drillData),
      // bottomNavigationBar: MyNavBar(location: MyNavBarLocation.stats),
    );
  }

  Widget _buildBody(BuildContext context, DrillData drillData) {
    return SingleChildScrollView(
      child: Column(children: [
        DrillChartsWidget(
            staticDrills: staticDrills,
            resultsDb: resultsDb,
            drillData: drillData),
        const Divider(),
        WeeklyChartWidget(
          staticDrills: staticDrills,
          resultsDb: resultsDb,
          drillData: drillData,
        ),
      ]),
    );
  }
}
