import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ft3/duration_formatter.dart';
import 'package:ft3/percent_fomatter.dart';

import 'date_formatter.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'results_widget.dart';

final _log = Log.get('daily_drills');

class DailyDrillsScreen extends StatelessWidget {
  static const routeName = '/daily';

  final ResultsDatabase resultsDb;
  DateTime _day;

  DailyDrillsScreen(this.resultsDb);

  @override
  Widget build(BuildContext context) {
    _day = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: MyAppBar(title: '${DateFormatter.format(_day)}').build(context),
      body: _DailyDrillList(resultsDb, _day),
      bottomNavigationBar: MyNavBar(MyNavBarLocation.STATS),
    );
  }
}

class _DailyDrillList extends StatefulWidget {
  final ResultsDatabase resultsDb;
  final DateTime day;

  _DailyDrillList(this.resultsDb, this.day);

  @override
  State<StatefulWidget> createState() => _DailyDrillListState();
}

class _PanelData {
  final DrillSummary drill;
  bool isExpanded = false;

  _PanelData(this.drill);
}

class _DailyDrillListState extends State<_DailyDrillList> {
  Future<List<_PanelData>> _panelFuture;

  @override
  void initState() {
    super.initState();
    _panelFuture = _loadDays();
  }

  Future<List<_PanelData>> _loadDays() async {
    final start = DateTime(widget.day.year, widget.day.month, widget.day.day);
    final end = DateTime(start.year, start.month, start.day + 1);
    List<DrillSummary> drills = await widget.resultsDb.summariesDao
        .loadDrillsByDate(widget.resultsDb, start, end);
    _log.info('Day: $start loaded ${drills.length} drills');
    return drills.map((drill) => _PanelData(drill)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: _panelFuture, builder: _buildDay);
  }

  Widget _buildDay(
      BuildContext context, AsyncSnapshot<List<_PanelData>> snapshot) {
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
        child: Container(child: _ExpandableDrillList(snapshot.data)));
  }
}

class _ExpandableDrillList extends StatefulWidget {
  final List<_PanelData> panelData;

  _ExpandableDrillList(this.panelData);

  @override
  State<StatefulWidget> createState() => _ExpandableDrillListState();
}

class _ExpandableDrillListState extends State<_ExpandableDrillList> {
  @override
  Widget build(BuildContext context) {
    List<ExpansionPanel> panels = widget.panelData.map(_buildPanel).toList();
    return ExpansionPanelList(
        children: panels,
        expansionCallback: _expansionCallback,
        expandedHeaderPadding: EdgeInsets.zero);
  }

  void _expansionCallback(int panelIndex, bool currentExpanded) {
    setState(() {
      widget.panelData[panelIndex].isExpanded = !currentExpanded;
    });
  }

  ExpansionPanel _buildPanel(_PanelData panelData) {
    return ExpansionPanel(
        canTapOnHeader: true,
        headerBuilder: (BuildContext context, bool expanded) =>
            _buildHeader(context, panelData.drill),
        body: _DailyDrillDetails(panelData.drill),
        isExpanded: panelData.isExpanded);
  }

  Widget _buildHeader(BuildContext context, DrillSummary drill) {
    return ListTile(
        title: _title(drill),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16));
  }

  Widget _title(DrillSummary drill) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(drill.drill.drill),
      Text(DurationFormatter.format(drill.drill.elapsed)),
    ]);
  }
}

// TODO: pull this out and use it in the practice done screen.
// add tap targets to lead to per-drill and per-action stats over time.
class _DailyDrillDetails extends StatelessWidget {
  final DrillSummary drill;

  _DailyDrillDetails(this.drill);

  Widget build(BuildContext context) {
    final List<DataColumn> columns = [
      DataColumn(label: Text('Action')),
      DataColumn(label: Text('Reps')),
      DataColumn(label: Text('Accuracy')),
    ];
    final List<DataRow> rows = [];
    final overall =
        StoredAction(action: 'Overall', reps: drill.reps, good: drill.good);
    rows.add(_buildRow(overall));
    rows.addAll(drill.actions.values.map((action) => _buildRow(action)));
    return DataTable(columns: columns, rows: rows);
  }

  DataRow _buildRow(StoredAction action) {
    final List<DataCell> cells = [];
    cells.add(DataCell(Text(action.action)));
    if (drill.drill.tracking) {
      cells.add(DataCell(Text('${action.good}/${action.reps}')));
    } else {
      cells.add(DataCell(Text('${action.reps}')));
    }
    final accuracy =
        drill.drill.tracking ? PercentFormatter.format(action.accuracy) : '--';
    cells.add(DataCell(Text('$accuracy')));
    return DataRow(cells: cells);
  }
}
