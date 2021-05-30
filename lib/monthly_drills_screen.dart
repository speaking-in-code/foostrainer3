import 'package:flutter/material.dart';

import 'monthly_drills_widget.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'results_db.dart';

class MonthlyDrillsScreen extends StatefulWidget {
  static const routeName = '/monthly';

  static void navigate(BuildContext context) =>
      Navigator.pushNamed(context, routeName);

  final ResultsDatabase resultsDb;

  MonthlyDrillsScreen({this.resultsDb});

  @override
  State<StatefulWidget> createState() => _MonthlyDrillsScreenState();
}

class _MonthlyDrillsScreenState extends State<MonthlyDrillsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'History').build(context),
      body: MonthlyDrillsWidget(widget.resultsDb),
      bottomNavigationBar: MyNavBar.forNormalNav(MyNavBarLocation.monthly),
    );
  }
}
