import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:ft3/aggregated_drill_summary.dart';

import 'chart_utils.dart' as chart_utils;
import 'results_db.dart';
import 'results_entities.dart';
import 'spinner.dart';
import 'titled_card.dart';

class RepsOverTimeChart extends StatelessWidget {
  static const title = 'Reps Over Time';
  final Future<List<AggregatedDrillSummary>> drillHistory;

  RepsOverTimeChart({this.drillHistory});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: drillHistory,
        builder:
            (context, AsyncSnapshot<List<AggregatedDrillSummary>> snapshot) {
          if (snapshot.hasError) {
            return TitledCard(
                title: title, child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return TitledCard(title: title, child: Spinner());
          }
          final series = _toRepsSeries(snapshot.data);
          return TitledCard(
              title: 'Reps Over Time',
              child: chart_utils.paddedChart(_chart(series)));
        });
  }

  charts.Series<AggregatedDrillSummary, DateTime> _toRepsSeries(
      List<AggregatedDrillSummary> data) {
    return charts.Series<AggregatedDrillSummary, DateTime>(
        id: 'reps',
        domainFn: (AggregatedDrillSummary item, _) => item.startDay,
        measureFn: (AggregatedDrillSummary item, _) => item.reps,
        data: data);
  }

  Widget _chart(charts.Series<AggregatedDrillSummary, DateTime> series) {
    final endTime = series.data.last.startDay;
    DateTime startTime = series.data.first.startDay;
    if (series.data.length > chart_utils.maxWeeksDisplayed) {
      startTime = series
          .data[series.data.length - chart_utils.maxWeeksDisplayed].startDay;
    }
    return charts.TimeSeriesChart([series],
        animate: true,
        defaultRenderer: charts.BarRendererConfig<DateTime>(),
        defaultInteractions: false,
        behaviors: [
          charts.SlidingViewport(),
          charts.PanAndZoomBehavior(),
          charts.DomainHighlighter(),
          charts.SelectNearest(),
        ],
        primaryMeasureAxis: chart_utils.numericAxisSpec,
        domainAxis: chart_utils.dateTimeAxis(startTime, endTime));
  }
}
