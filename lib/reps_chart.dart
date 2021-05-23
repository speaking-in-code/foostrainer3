import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'chart_utils.dart' as chart_utils;
import 'results_db.dart';
import 'titled_card.dart';
import 'spinner.dart';

class RepsChart extends StatelessWidget {
  final Future<List<AggregatedActionReps>> data;
  final bool byAction;

  RepsChart({@required this.data, this.byAction = false});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: _buildCard);
  }

  Widget _buildCard(BuildContext context,
      AsyncSnapshot<List<AggregatedActionReps>> snapshot) {
    return TitledCard(title: 'Reps', child: _buildChart(context, snapshot));
  }

  Widget _buildChart(BuildContext context,
      AsyncSnapshot<List<AggregatedActionReps>> snapshot) {
    if (snapshot.hasError) {
      return Text('${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return Spinner();
    }
    int desiredLegendRows = 2;
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      desiredLegendRows = 1;
    }
    final series = _makeSeries(snapshot.data);
    final chart = charts.TimeSeriesChart(series,
        animate: true,
        behaviors: [
          charts.SeriesLegend(
            position: charts.BehaviorPosition.bottom,
            desiredMaxRows: desiredLegendRows,
            horizontalFirst: false,
            showMeasures: true,
          ),
          charts.SlidingViewport(),
          charts.PanAndZoomBehavior(),
          charts.SelectNearest(),
          charts.DomainHighlighter(),
        ],
        domainAxis:
            charts.DateTimeAxisSpec(renderSpec: chart_utils.dateRenderSpec));
    return chart_utils.paddedChart(chart);
  }

  List<charts.Series<AggregatedActionReps, DateTime>> _makeSeries(
      List<AggregatedActionReps> data) {}
}
