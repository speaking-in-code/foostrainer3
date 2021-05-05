import 'package:flutter/material.dart';
import 'package:ft3/monthly_drills_widget.dart';

import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'results_db.dart';

class StatsScreen extends StatelessWidget {
  static const routeName = '/stats';
  final ResultsDatabase resultsDb;

  StatsScreen(this.resultsDb);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: MyAppBar(
          title: 'Stats',
          bottom: TabBar(
            tabs: [
              Tab(text: 'Recent'),
              Tab(text: 'Drills'),
              Tab(text: 'Actions'),
            ],
          ),
        ).build(context),
        body: TabBarView(
          // TODO(brian): Implement child widgets that display results
          // from the results db in various fields.
          children: [
            MonthlyDrillsWidget(resultsDb),
            Icon(Icons.directions_transit),
            Icon(Icons.directions_bike),
          ],
        ),
        bottomNavigationBar: MyNavBar(MyNavBarLocation.STATS),
      ),
    );
  }
}
