import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;

import 'chart_utils.dart' as chart_utils;
import 'drill_data.dart';
import 'percent_formatter.dart';
import 'results_db.dart';
import 'spinner.dart';
import 'static_drills.dart';

class DrillChartsWidget extends StatefulWidget {
  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;
  final DrillData drillData;

  DrillChartsWidget(
      {required this.staticDrills,
      required this.resultsDb,
      required this.drillData});

  @override
  State<StatefulWidget> createState() => DrillChartsWidgetState();
}

class DrillChartsWidgetState extends State<DrillChartsWidget> {
  late final Future<List<AggregatedActionReps>> _actions;

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

  Widget _handleSnapshot(BuildContext context,
      AsyncSnapshot<List<AggregatedActionReps>> snapshot) {
    if (snapshot.hasError) {
      return Text('Oh snap: ${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return Spinner();
    }
    if (snapshot.data!.isEmpty) {
      return Text('No data, go practice.');
    }
    return SingleChildScrollView(
        child: Column(children: [
      _buildAccuracyChart(context, snapshot.data!),
    ]));
  }

  Widget _buildAccuracyChart(
      BuildContext context, List<AggregatedActionReps> data) {
    final split = _splitByAction(data);
    final series = <charts.Series<AggregatedActionReps, DateTime>>[];
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
        primaryMeasureAxis: chart_utils.percentAxisSpec,
        domainAxis:
            charts.DateTimeAxisSpec(renderSpec: chart_utils.dateRenderSpec));
    return chart_utils.paddedChart(chart);
  }

  Map<String, List<AggregatedActionReps>> _splitByAction(
      List<AggregatedActionReps> data) {
    final actionTable = SplayTreeMap<String, List<AggregatedActionReps>>();
    data.forEach((AggregatedActionReps item) {
      if (item.accuracy == null) return;
      final list = actionTable.putIfAbsent(item.action, () => []);
      list.add(item);
    });
    actionTable.values.forEach((List<AggregatedActionReps> items) {
      items.sort((AggregatedActionReps a, AggregatedActionReps b) =>
          a.startDay.compareTo(b.startDay));
    });
    return actionTable;
  }

  charts.Series<AggregatedActionReps, DateTime> _makeAccuracySeries(
      String action, List<AggregatedActionReps> weeks) {
    return charts.Series<AggregatedActionReps, DateTime>(
        id: action,
        domainFn: (AggregatedActionReps reps, _) => reps.startDay,
        measureFn: (AggregatedActionReps reps, _) => reps.accuracy,
        data: weeks);
  }
}
