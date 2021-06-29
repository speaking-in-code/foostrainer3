import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'drill_data.dart';
import 'duration_formatter.dart';
import 'percent_formatter.dart';
import 'results_entities.dart';

class StatsGridWidget extends StatelessWidget {
  final DrillSummary? summary;
  final DrillData? drillData;

  StatsGridWidget({this.summary, this.drillData});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      childAspectRatio: 2,
      crossAxisCount: 2,
      shrinkWrap: true,
      primary: false, // disables scroll effects
      mainAxisSpacing: 0,
      crossAxisSpacing: 0,
      children: [
        _date(context),
        _time(context),
        _duration(context),
        _reps(context),
        // _accuracy(context),
      ],
    );
  }

  Widget _date(BuildContext context) {
    return _labeledData(context,
        label: 'Date', data: DateFormat.yMd().format(summary!.drill.startTime));
  }

  Widget _time(BuildContext context) {
    return _labeledData(context,
        label: 'Time', data: DateFormat.jm().format(summary!.drill.startTime));
  }

  Widget _duration(BuildContext context) {
    return _labeledData(context,
        label: 'Duration',
        data: DurationFormatter.format(summary!.drill.elapsed));
  }

  Widget _reps(BuildContext context) {
    String repsString = '${summary!.reps}';
    if (summary!.good != null) {
      repsString = '${summary!.good}/${summary!.reps}';
    }
    return _labeledData(context, label: 'Reps', data: repsString);
  }

  Widget _labeledData(BuildContext context, {required String label, required String data}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text('$label', style: _headerStyle(context))),
        Text('$data', style: Theme.of(context).textTheme.headline5),
      ],
    );
  }

  TextStyle _headerStyle(BuildContext context) {
    TextStyle headerStyle = Theme.of(context).textTheme.subtitle1!;
    return headerStyle.apply(color: headerStyle.color!.withOpacity(.8));
  }
}
