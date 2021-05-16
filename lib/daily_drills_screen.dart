import 'dart:async';
import 'package:flutter/material.dart';

import 'date_formatter.dart';
import 'drill_summary_list_widget.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'static_drills.dart';

class DailyDrillsScreen extends StatelessWidget {
  static const routeName = '/daily';
  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;

  DailyDrillsScreen({this.staticDrills, this.resultsDb})
      : assert(staticDrills != null),
        assert(resultsDb != null);

  @override
  Widget build(BuildContext context) {
    DateTime day = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: MyAppBar(title: '${DateFormatter.format(day)}').build(context),
      body: _DailyDrillList(
          staticDrills: staticDrills, resultsDb: resultsDb, day: day),
      bottomNavigationBar: MyNavBar(location: MyNavBarLocation.STATS),
    );
  }
}

class _DailyDrillList extends StatefulWidget {
  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;
  final DateTime day;

  _DailyDrillList({this.staticDrills, this.resultsDb, this.day});

  @override
  State<StatefulWidget> createState() => _DailyDrillListState();
}

class _DailyDrillListState extends State<_DailyDrillList> {
  Future<List<DrillSummary>> _panelFuture;

  @override
  void initState() {
    super.initState();
    _panelFuture = _loadDays();
  }

  Future<List<DrillSummary>> _loadDays() async {
    final start = DateTime(widget.day.year, widget.day.month, widget.day.day);
    final end = DateTime(start.year, start.month, start.day + 1);
    return widget.resultsDb.summariesDao
        .loadDrillsByDate(widget.resultsDb, start, end);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: _panelFuture, builder: _buildDay);
  }

  Widget _buildDay(
      BuildContext context, AsyncSnapshot<List<DrillSummary>> snapshot) {
    if (snapshot.hasError) {
      return Text('${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return Center(child: CircularProgressIndicator());
    }
    if (snapshot.data.isEmpty) {
      return Center(child: Text('No drills, go practice!'));
    }
    return SingleChildScrollView(
        child: Container(
            child: DrillSummaryListWidget(
                staticDrills: widget.staticDrills, drills: snapshot.data)));
  }
}
