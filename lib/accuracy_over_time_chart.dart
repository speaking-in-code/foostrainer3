//import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import 'chart_utils.dart' as chart_utils;
import 'results_db.dart';
import 'results_entities.dart';
import 'titled_section.dart';

class AccuracyOverTimeChart extends StatelessWidget {
  static const title = 'Accuracy Over Time';
  final AggregationLevel aggLevel;
  final List<AggregatedDrillSummary> drillHistory;

  AccuracyOverTimeChart({@required this.aggLevel, @required this.drillHistory})
      : assert(aggLevel != null),
        assert(drillHistory != null);

  @override
  Widget build(BuildContext context) {
    return Text('Chart Disabled: $title');
    //final series = _toRepsSeries(drillHistory);
    //return chart_utils.paddedChart(_chart(series));
  }

/*
  charts.Series<AggregatedDrillSummary, DateTime> _toRepsSeries(
      List<AggregatedDrillSummary> data) {
    return charts.Series<AggregatedDrillSummary, DateTime>(
        id: 'accuracy',
        domainFn: (AggregatedDrillSummary item, _) => item.startDay,
        measureFn: (AggregatedDrillSummary item, _) => item.accuracy,
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
        primaryMeasureAxis: chart_utils.percentAxisSpec,
        domainAxis: chart_utils.dateTimeAxis(aggLevel, series));
  }
  */
}
