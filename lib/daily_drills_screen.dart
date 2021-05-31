import 'dart:async';
import 'package:flutter/material.dart';

import 'date_formatter.dart';
import 'drill_data.dart';
import 'drill_list_widget.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'results_screen.dart';
import 'spinner.dart';
import 'static_drills.dart';

class DailyDrillsScreen extends StatelessWidget {
  static const routeName = '/daily';

  static void push(BuildContext context, DateTime date) =>
      Navigator.pushNamed(context, routeName, arguments: date);

  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;

  DailyDrillsScreen({this.staticDrills, this.resultsDb})
      : assert(staticDrills != null),
        assert(resultsDb != null);

  @override
  Widget build(BuildContext context) {
    DateTime day = ModalRoute.of(context).settings.arguments;
    final startDate = DateTime(day.year, day.month, day.day);
    final endDate =
        DateTime(startDate.year, startDate.month, startDate.day + 1);
    return Scaffold(
      appBar: MyAppBar(title: '${DateFormatter.format(day)}').build(context),
      body: DrillListWidget(
          staticDrills: staticDrills,
          resultsDb: resultsDb,
          startDate: startDate,
          endDate: endDate),
      bottomNavigationBar: MyNavBar.forNormalNav(MyNavBarLocation.monthly),
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
        .loadDrillsByDate(widget.resultsDb, start: start, end: end);
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
      return Spinner();
    }
    if (snapshot.data.isEmpty) {
      return Center(child: Text('No drills, go practice!'));
    }
    return ListView(children: snapshot.data.map((e) => _toTile(e)).toList());
  }

  Widget _toTile(DrillSummary drill) {
    final DrillData data = widget.staticDrills.getDrill(drill.drill.drill);
    final onTap = () => _onDrillSelect(drill.drill.id, data);
    return ListTile(
      title: Text(data.type),
      subtitle: Text(data.name),
      onTap: onTap,
      trailing: IconButton(
        icon: Icon(Icons.expand_more),
        onPressed: onTap,
      ),
    );
  }

  void _onDrillSelect(int drillId, DrillData data) {
    ResultsScreen.push(context, drillId, data);
  }
}
