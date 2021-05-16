import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

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
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: Column(children: [
      SizedBox(height: 250.0, child: chart),
    ]),
  );
}
