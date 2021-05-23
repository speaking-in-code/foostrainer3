import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import 'results_db.dart';

// About two years worth of data.
const maxWeeks = 52 * 2;
const maxWeeksDisplayed = 4;

const axisLabelStyle = charts.TextStyleSpec(
  fontSize: 10,
  color: charts.MaterialPalette.white,
);

final axisLineStyle = charts.LineStyleSpec(
    thickness: 0, color: charts.MaterialPalette.gray.shadeDefault);

final numericAxisSpec = charts.NumericAxisSpec(
  renderSpec: charts.GridlineRendererSpec(
    labelStyle: axisLabelStyle,
    lineStyle: axisLineStyle,
  ),
);

const dateRenderSpec = charts.SmallTickRendererSpec<DateTime>(
  labelStyle: axisLabelStyle,
);

const titleStyle = charts.TextStyleSpec(color: charts.MaterialPalette.white);

charts.DateTimeAxisSpec dateTimeAxis(DateTime start, DateTime end) {
  return charts.DateTimeAxisSpec(
    renderSpec: dateRenderSpec,
    viewport: charts.DateTimeExtents(start: start, end: end),
  );
}

Widget paddedChart(Widget chart) {
  return Container(
    padding: EdgeInsets.all(10.0),
    // margin: EdgeInsets.only(bottom: 50),
    child: Column(children: [
      SizedBox(height: 250.0, child: chart),
    ]),
  );
}

List<charts.Series<AggregatedActionReps, DateTime>> toRepsSeries(
    Map<String, List<AggregatedActionReps>> input) {
  return _toSeries(input, (AggregatedActionReps item) => item.reps);
}

List<charts.Series<AggregatedActionReps, DateTime>> toAccuracySeries(
    Map<String, List<AggregatedActionReps>> input) {
  return _toSeries(input, (AggregatedActionReps item) => item.accuracy);
}

typedef _MeasureExtractor = num Function(AggregatedActionReps datum);

List<charts.Series<AggregatedActionReps, DateTime>> _toSeries(
    Map<String, List<AggregatedActionReps>> input,
    _MeasureExtractor extractorFn) {
  final series = <charts.Series<AggregatedActionReps, DateTime>>[];
  input.forEach((String id, List<AggregatedActionReps> data) {
    series.add(charts.Series<AggregatedActionReps, DateTime>(
        id: id,
        domainFn: (AggregatedActionReps item, _) => item.startDay,
        measureFn: (AggregatedActionReps item, _) => extractorFn(item),
        data: data));
  });
  return series;
}
