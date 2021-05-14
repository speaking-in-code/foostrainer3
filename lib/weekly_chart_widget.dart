import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/rendering.dart';
import 'package:ft3/percent_fomatter.dart';

import 'log.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'spinner.dart';

final _log = Log.get('weekly_chart_widget');

// Next steps:
// Add accuracy as a filler bar in the reps column
// Display table below for selected week
// onClick:
// - loadDrillsbyDate
// - display grid with drills
// - make grid clickable for drill down into specific drills.
class WeeklyChartWidget extends StatefulWidget {
  final ResultsDatabase resultsDb;
  final String drill;
  final String action;

  WeeklyChartWidget({this.resultsDb, this.drill, this.action});

  @override
  State<StatefulWidget> createState() => _WeeklyChartWidgetState();
}

class _WeeklyChartWidgetState extends State<WeeklyChartWidget> {
  // About two years worth of data.
  static const _maxWeeks = 52 * 2;
  static const _displayedTime = Duration(days: 28);

  static final _axisLabelStyle = charts.TextStyleSpec(
    fontSize: 10,
    color: charts.MaterialPalette.white,
  );

  static final _axisLineStyle = charts.LineStyleSpec(
      thickness: 0, color: charts.MaterialPalette.gray.shadeDefault);

  static final _repsAxis = charts.NumericAxisSpec(
    renderSpec: charts.GridlineRendererSpec(
      labelStyle: _axisLabelStyle,
      lineStyle: _axisLineStyle,
    ),
  );

  static final _dateRenderSpec = charts.SmallTickRendererSpec<DateTime>(
    labelStyle: _axisLabelStyle,
  );

  Future<List<WeeklyDrillSummary>> _weeks;
  final ValueNotifier<WeeklyDrillSummary> _selected = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _weeks = widget.resultsDb.summariesDao.loadWeeklyDrills(
        numWeeks: _maxWeeks,
        offset: 0,
        drill: widget.drill,
        action: widget.action);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: _weeks, builder: _buildSummaries);
  }

  Widget _buildSummaries(
      BuildContext context, AsyncSnapshot<List<WeeklyDrillSummary>> snapshot) {
    if (snapshot.hasError) {
      return Text('Oh snap: ${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return Spinner();
    }
    if (snapshot.data.isEmpty) {
      return Text('No data, go practice.');
    }
    ;
    return SingleChildScrollView(
        child: Column(children: [
      _buildChart(context, snapshot.data),
      _WeekSummary(resultsDb: widget.resultsDb, selected: _selected),
    ]));
  }

  int _estGood(WeeklyDrillSummary summary) {
    double multiplier = summary.accuracy ?? 0.0;
    return (summary.reps * multiplier).round();
  }

  int _estMissed(WeeklyDrillSummary summary) {
    return summary.reps - _estGood(summary);
  }

  Widget _buildChart(BuildContext context, List<WeeklyDrillSummary> data) {
    final endTime = data.last.startDay;
    final startTime = endTime.subtract(_displayedTime);
    final good = charts.Series<WeeklyDrillSummary, DateTime>(
      id: 'Good',
      seriesColor: charts.MaterialPalette.blue.shadeDefault.lighter,
      domainFn: (WeeklyDrillSummary summary, _) => summary.startDay,
      measureFn: (WeeklyDrillSummary summary, _) => _estGood(summary),
      data: data,
    );
    final missed = charts.Series<WeeklyDrillSummary, DateTime>(
      id: 'Missed',
      seriesColor: charts.MaterialPalette.blue.shadeDefault,
      domainFn: (WeeklyDrillSummary summary, _) => summary.startDay,
      measureFn: (WeeklyDrillSummary summary, _) => _estMissed(summary),
      data: data,
    );
    final chart = charts.TimeSeriesChart([good, missed],
        animate: true,
        defaultRenderer: charts.BarRendererConfig<DateTime>(
          groupingType: charts.BarGroupingType.stacked,
        ),
        defaultInteractions: false,
        behaviors: [
          charts.SlidingViewport(),
          charts.PanAndZoomBehavior(),
          charts.DomainHighlighter(),
          charts.SelectNearest(),
          // TODO(brian): this isn't working, the initial selection doesn't
          // actually happen. Might be a bug in the stacked bar chart implementation?
          charts.InitialSelection(selectedDataConfig: [
            charts.SeriesDatumConfig<DateTime>(missed.id, data.last.startDay),
            charts.SeriesDatumConfig<DateTime>(good.id, data.last.startDay),
          ])
        ],
        selectionModels: [
          new charts.SelectionModelConfig(
            type: charts.SelectionModelType.info,
            changedListener: _onSelectionChanged,
          )
        ],
        primaryMeasureAxis: _repsAxis,
        domainAxis: charts.DateTimeAxisSpec(
            renderSpec: _dateRenderSpec,
            viewport: charts.DateTimeExtents(start: startTime, end: endTime)));
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(children: [
        SizedBox(height: 250.0, child: chart),
      ]),
    );
  }

  void _onSelectionChanged(charts.SelectionModel<DateTime> selected) {
    if (selected.selectedDatum != null && selected.selectedDatum.isNotEmpty) {
      WeeklyDrillSummary week = selected.selectedDatum[0].datum;
      _selected.value = week;
    } else {
      _selected.value = null;
    }
  }
}

class _WeekSummary extends StatefulWidget {
  final ResultsDatabase resultsDb;
  final ValueNotifier<WeeklyDrillSummary> selected;

  _WeekSummary({this.resultsDb, this.selected});

  @override
  State<StatefulWidget> createState() => _WeekSummaryState();
}

class _DrillAccuracy {
  String name;
  int totalReps = 0;
  int trackedReps = 0;
  int goodTrackedReps = 0;

  _DrillAccuracy(this.name);

  String get goodEstimate {
    if (accuracy == null) {
      return '--';
    }
    return (accuracy * totalReps).round().toString();
  }

  double get accuracy =>
      (trackedReps > 0 ? goodTrackedReps / trackedReps : null);

  String get stringAccuracy {
    if (accuracy == null) {
      return '--';
    }
    return PercentFormatter.format(accuracy);
  }
}

class _DrillAccuracyTable {
  SplayTreeMap<String, _DrillAccuracy> drills = SplayTreeMap();
}

class _WeekSummaryState extends State<_WeekSummary> {
  WeeklyDrillSummary _week;
  Future<_DrillAccuracyTable> _table;

  @override
  void initState() {
    super.initState();
    _table = _loadWeeks();
    widget.selected.addListener(_onWeekChanged);
  }

  @override
  void dispose() {
    widget.selected.removeListener(_onWeekChanged);
    super.dispose();
  }

  void _onWeekChanged() {
    setState(() {
      _week = widget.selected.value;
      _table = _loadWeeks();
    });
  }

  Future<_DrillAccuracyTable> _loadWeeks() async {
    final table = _DrillAccuracyTable();
    if (_week == null) {
      return Future.value(table);
    }
    // TODO(brian): add test case for day of week alignment.
    // UTC 1620001414 is a good edge case, it's Monday May 3 UTC, but
    // Sunday May 2 PDT. The logic here needs line up with the
    // "weekday 0", "-6 days" logic in the per-week summary SQL query.
    final start = _week.startDay.subtract(Duration(days: 1));
    final end = _week.endDay;
    List<DrillSummary> drills = await widget.resultsDb.summariesDao
        .loadDrillsByDate(widget.resultsDb, start, end);
    drills.forEach((DrillSummary drill) {
      _DrillAccuracy accuracy = table.drills.putIfAbsent(
          drill.drill.drill, () => _DrillAccuracy(drill.drill.drill));
      accuracy.totalReps += drill.reps;
      if (drill.good != null) {
        accuracy.trackedReps += drill.reps;
        accuracy.goodTrackedReps += drill.good;
      }
    });
    return table;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: _table, builder: _buildTable);
  }

  Widget _buildTable(
      BuildContext context, AsyncSnapshot<_DrillAccuracyTable> snapshot) {
    if (snapshot.hasError) {
      return Text('Oh snap: ${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return Spinner();
    }
    final rows = <Widget>[];
    snapshot.data.drills.values.forEach((_DrillAccuracy drill) {
      rows.add(const Divider());
      String repsText;
      if (drill.accuracy == null) {
        repsText = 'Reps: ${drill.totalReps}';
      } else {
        repsText =
            'Reps: ${drill.totalReps}   Accuracy: ${drill.stringAccuracy}';
      }
      rows.add(Card(
        child: ListTile(
          title: Text(drill.name),
          subtitle: Text(repsText),
          trailing: Icon(Icons.timeline),
          dense: true,
        ),
      ));
    });
    return Column(children: rows);
  }
}
