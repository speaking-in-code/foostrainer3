import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/rendering.dart';
import 'package:ft3/drill_data.dart';
import 'package:ft3/log.dart';

import 'chart_utils.dart' as chart_utils;
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
  Future<List<AggregatedDrillSummary>> _weeks;
  final ValueNotifier<AggregatedDrillSummary> _selected = ValueNotifier(null);

  @override
  void initState() {
    String drill = widget.drillData?.fullName;
    _log.info('Loading weekly summary for $drill');
    super.initState();
    _weeks = widget.resultsDb.summariesDao.loadWeeklyDrills(
        numWeeks: chart_utils.maxWeeks, offset: 0, drill: drill);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: _weeks, builder: _buildSummaries);
  }

  Widget _buildSummaries(BuildContext context,
      AsyncSnapshot<List<AggregatedDrillSummary>> snapshot) {
    if (snapshot.hasError) {
      return Text('Oh snap: ${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return Spinner();
    }
    if (snapshot.data.isEmpty) {
      return Text('No data, go practice.');
    }
    return Column(children: [
      _buildChart(context, snapshot.data),
      const Divider(),
      _WeekSummary(
          staticDrills: widget.staticDrills,
          resultsDb: widget.resultsDb,
          drill: widget.drillData,
          selected: _selected),
    ]);
  }

  int _estGood(AggregatedDrillSummary summary) {
    double multiplier = summary.accuracy ?? 0.0;
    return (summary.reps * multiplier).round();
  }

  int _estMissed(AggregatedDrillSummary summary) {
    return summary.reps - _estGood(summary);
  }

  Widget _buildChart(BuildContext context, List<AggregatedDrillSummary> data) {
    final endTime = data.last.startDay;
    DateTime startTime = data.first.startDay;
    if (data.length > chart_utils.maxWeeksDisplayed) {
      startTime = data[data.length - chart_utils.maxWeeksDisplayed].startDay;
    }
    // final startTime = endTime.subtract(_displayedTime);
    final good = charts.Series<AggregatedDrillSummary, DateTime>(
      id: 'Good',
      seriesColor: charts.MaterialPalette.blue.shadeDefault.lighter,
      domainFn: (AggregatedDrillSummary summary, _) => summary.startDay,
      measureFn: (AggregatedDrillSummary summary, _) => _estGood(summary),
      data: data,
    );
    final missed = charts.Series<AggregatedDrillSummary, DateTime>(
      id: 'Missed',
      seriesColor: charts.MaterialPalette.blue.shadeDefault,
      domainFn: (AggregatedDrillSummary summary, _) => summary.startDay,
      measureFn: (AggregatedDrillSummary summary, _) => _estMissed(summary),
      data: data,
    );
    final chart = charts.TimeSeriesChart([good, missed],
        animate: true,
        defaultRenderer: charts.BarRendererConfig<DateTime>(
          groupingType: charts.BarGroupingType.stacked,
        ),
        defaultInteractions: false,
        behaviors: [
          charts.ChartTitle('Weekly Reps',
              titleStyleSpec: chart_utils.titleStyle),
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
        primaryMeasureAxis: chart_utils.numericAxisSpec,
        domainAxis: chart_utils.dateTimeAxis(startTime, endTime));
    return chart_utils.paddedChart(chart);
  }

  void _onSelectionChanged(charts.SelectionModel<DateTime> selected) {
    if (selected.selectedDatum != null && selected.selectedDatum.isNotEmpty) {
      AggregatedDrillSummary week = selected.selectedDatum[0].datum;
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
  final ValueNotifier<AggregatedDrillSummary> selected;

  _WeekSummary({this.staticDrills, this.resultsDb, this.drill, this.selected});

  @override
  State<StatefulWidget> createState() => _WeekSummaryState();
}

class _WeekSummaryState extends State<_WeekSummary> {
  AggregatedDrillSummary _week;
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
    List<DrillSummary> drills = await widget.resultsDb.summariesDao
        .loadDrillsByDate(widget.resultsDb, _week.startDay, _week.endDay,
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
