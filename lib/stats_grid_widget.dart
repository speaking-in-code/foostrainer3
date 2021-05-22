import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'date_formatter.dart';
import 'drill_data.dart';
import 'duration_formatter.dart';
import 'percent_formatter.dart';
import 'results_entities.dart';

class StatsGridWidget extends StatelessWidget {
  final DrillSummary summary;
  final DrillData drillData;

  StatsGridWidget({this.summary, this.drillData});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      childAspectRatio: 2,
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _time(context),
        _duration(context),
        _type(context),
        _reps(context),
        _success(context),
        _accuracy(context),
      ],
    );
  }

  Widget _type(BuildContext context) {
    return _labeledData(context, label: 'Type', data: drillData.type);
  }

  Widget _time(BuildContext context) {
    return _labeledData(context,
        label: 'Time', data: DateFormat.jm().format(summary.drill.startTime));
  }

  Widget _duration(BuildContext context) {
    return _labeledData(context,
        label: 'Duration',
        data: DurationFormatter.format(summary.drill.elapsed));
  }

  Widget _reps(BuildContext context) {
    return _labeledData(context, label: 'Reps', data: '${summary.reps}');
  }

  Widget _success(BuildContext context) {
    return _labeledData(context,
        label: 'Success',
        data: summary.good != null ? '${summary.good}' : '--');
  }

  Widget _accuracy(BuildContext context) {
    return _labeledData(context,
        label: 'Accuracy',
        data: PercentFormatter.formatAccuracy(
            trackedReps: summary.reps, trackedGood: summary.good));
  }

  Widget _labeledData(BuildContext context, {String label, String data}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$label', style: Theme.of(context).textTheme.subtitle1),
        Text('$data', style: Theme.of(context).textTheme.headline5),
      ],
    );
  }
}
