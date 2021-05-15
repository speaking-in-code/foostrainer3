import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/rendering.dart';
import 'package:ft3/drill_data.dart';
import 'package:ft3/log.dart';

import 'drill_summary_list_widget.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'spinner.dart';
import 'static_drills.dart';

final _log = Log.get('weekly_chart_widget');

// Next steps:
// - add zoom out option, for sparser practice sessions. Either pinch to
//   zoom, or a slider.
// - display per-action accuracy... somehow. Multiple columns?
class WeeklyChartWidget extends StatefulWidget {
  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;
  final DrillData drillData;

  WeeklyChartWidget({this.staticDrills, this.resultsDb, this.drillData});

  @override
  State<StatefulWidget> createState() => _WeeklyChartWidgetState();
}

class _WeeklyChartWidgetState extends State<WeeklyChartWidget> {
  // About two years worth of data.
  static const _maxWeeks = 52 * 2;
  static const _maxWeeksDisplayed = 4;

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
    String drill = widget.drillData?.fullName;
    _log.info('Loading weekly summary for $drill');
    super.initState();
    _weeks = widget.resultsDb.summariesDao
        .loadWeeklyDrills(numWeeks: _maxWeeks, offset: 0, drill: drill);
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
    return SingleChildScrollView(
        child: Column(children: [
      _buildChart(context, snapshot.data),
      const Divider(),
      _WeekSummary(
          staticDrills: widget.staticDrills,
          resultsDb: widget.resultsDb,
          drill: widget.drillData,
          selected: _selected),
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
    DateTime startTime = data.first.startDay;
    if (data.length > _maxWeeksDisplayed) {
      startTime = data[data.length - _maxWeeksDisplayed].startDay;
    }
    // final startTime = endTime.subtract(_displayedTime);
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
  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;
  final DrillData drill;
  final ValueNotifier<WeeklyDrillSummary> selected;

  _WeekSummary({this.staticDrills, this.resultsDb, this.drill, this.selected});

  @override
  State<StatefulWidget> createState() => _WeekSummaryState();
}

class _WeekSummaryState extends State<_WeekSummary> {
  WeeklyDrillSummary _week;
  Future<List<DrillSummary>> _table;

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

  Future<List<DrillSummary>> _loadWeeks() async {
    if (_week == null) {
      return Future.value([]);
    }
    // TODO(brian): add test case for day of week alignment.
    // UTC 1620001414 is a good edge case, it's Monday May 3 UTC, but
    // Sunday May 2 PDT. The logic here needs line up with the
    // "weekday 0", "-6 days" logic in the per-week summary SQL query.
    final start = _week.startDay.subtract(Duration(days: 1));
    final end = _week.endDay;
    List<DrillSummary> drills = await widget.resultsDb.summariesDao
        .loadDrillsByDate(widget.resultsDb, start, end,
            fullName: widget.drill?.fullName);
    return drills;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: _table, builder: _buildTable);
  }

  Widget _buildTable(
      BuildContext context, AsyncSnapshot<List<DrillSummary>> snapshot) {
    if (snapshot.hasError) {
      return Text('Oh snap: ${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return Spinner();
    }
    return DrillSummaryListWidget(
        staticDrills: widget.staticDrills, drills: snapshot.data);
  }
}
