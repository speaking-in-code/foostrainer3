import 'package:flutter/material.dart';

import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'results_db.dart';
import 'weekly_chart_widget.dart';

class StatsScreen extends StatelessWidget {
  static const routeName = '/stats';
  final ResultsDatabase resultsDb;

  StatsScreen(this.resultsDb);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Stats').build(context),
      body: WeeklyChartWidget(resultsDb: resultsDb),
      bottomNavigationBar: MyNavBar(MyNavBarLocation.STATS),
    );
  }
}
