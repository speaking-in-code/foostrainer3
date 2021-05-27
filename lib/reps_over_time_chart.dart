import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import 'chart_utils.dart' as chart_utils;
import 'results_entities.dart';
import 'titled_section.dart';

class RepsOverTimeChart extends StatelessWidget {
  static const title = 'Reps Over Time';
  final List<AggregatedDrillSummary> drillHistory;

  RepsOverTimeChart({this.drillHistory});

  @override
  Widget build(BuildContext context) {
    final series = _toRepsSeries(drillHistory);
    return chart_utils.paddedChart(_chart(series));
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
        domainAxis: chart_utils.dateTimeAxis(series));
  }
}
