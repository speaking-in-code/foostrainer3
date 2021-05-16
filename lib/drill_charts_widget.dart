import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'chart_utils.dart' as chart_utils;
import 'drill_data.dart';
import 'log.dart';
import 'percent_formatter.dart';
import 'results_db.dart';
import 'spinner.dart';
import 'static_drills.dart';

final _log = Log.get('drill_charts_widget');

class DrillChartsWidget extends StatefulWidget {
  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;
  final DrillData drillData;

  DrillChartsWidget({this.staticDrills, this.resultsDb, this.drillData});

  @override
  State<StatefulWidget> createState() => DrillChartsWidgetState();
}

class DrillChartsWidgetState extends State<DrillChartsWidget> {
  Future<List<WeeklyActionReps>> _actions;

  @override
  void initState() {
    super.initState();
    _actions = widget.resultsDb.summariesDao.loadWeeklyActionReps(
        widget.drillData.fullName, chart_utils.maxWeeks, 0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: _actions, builder: _handleSnapshot);
  }

  Widget _handleSnapshot(
      BuildContext context, AsyncSnapshot<List<WeeklyActionReps>> snapshot) {
    if (snapshot.hasError) {
      return Text('Oh snap: ${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return Spinner();
    }
    if (snapshot.data.isEmpty) {
      return Text('No data, go practice.');
    }
    return SingleChildScrollView(
        child: Column(children: [
      _buildAccuracyChart(context, snapshot.data),
    ]));
  }

  Widget _buildAccuracyChart(
      BuildContext context, List<WeeklyActionReps> data) {
    final split = _splitByAction(data);
    final series = <charts.Series<WeeklyActionReps, DateTime>>[];
    split.forEach((action, week) {
      series.add(_makeAccuracySeries(action, week));
    });
    int desiredLegendRows = 2;
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      desiredLegendRows = 1;
    }
    final chart = charts.TimeSeriesChart(series,
        animate: true,
        behaviors: [
          charts.SeriesLegend(
            position: charts.BehaviorPosition.bottom,
            desiredMaxRows: desiredLegendRows,
            horizontalFirst: false,
            showMeasures: true,
            measureFormatter: PercentFormatter.format,
          ),
          charts.ChartTitle('Accuracy', titleStyleSpec: chart_utils.titleStyle),
          charts.SlidingViewport(),
          charts.PanAndZoomBehavior(),
          charts.SelectNearest(),
          charts.DomainHighlighter(),
        ],
        primaryMeasureAxis: new charts.PercentAxisSpec(
            renderSpec: charts.GridlineRendererSpec(
          labelStyle: chart_utils.axisLabelStyle,
          lineStyle: chart_utils.axisLineStyle,
        )),
        domainAxis:
            charts.DateTimeAxisSpec(renderSpec: chart_utils.dateRenderSpec));
    return chart_utils.paddedChart(chart);
  }

  Map<String, List<WeeklyActionReps>> _splitByAction(
      List<WeeklyActionReps> data) {
    final actionTable = SplayTreeMap<String, List<WeeklyActionReps>>();
    data.forEach((WeeklyActionReps item) {
      if (item.accuracy == null) return;
      final list = actionTable.putIfAbsent(item.action, () => []);
      list.add(item);
    });
    actionTable.values.forEach((List<WeeklyActionReps> items) {
      items.sort((WeeklyActionReps a, WeeklyActionReps b) =>
          a.startDay.compareTo(b.startDay));
    });
    return actionTable;
  }

  charts.Series<WeeklyActionReps, DateTime> _makeAccuracySeries(
      String action, List<WeeklyActionReps> weeks) {
    return charts.Series<WeeklyActionReps, DateTime>(
        id: action,
        domainFn: (WeeklyActionReps reps, _) => reps.startDay,
        measureFn: (WeeklyActionReps reps, _) => reps.accuracy,
        data: weeks);
  }
}
