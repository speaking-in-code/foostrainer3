// Widget to display results from a drill. Contains the drill type, reps,
// time, success count, and accuracy.abstract

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ft3/percent_formatter.dart';

import 'duration_formatter.dart';
import 'results_entities.dart';

class ResultsWidget extends StatelessWidget {
  final DrillSummary summary;

  ResultsWidget({Key key, this.summary});

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = Theme.of(context).textTheme.headline5;
    labelStyle = labelStyle.copyWith(color: labelStyle.color.withOpacity(0.75));
    TextStyle dataStyle = Theme.of(context).textTheme.headline4;
    dataStyle = dataStyle.copyWith(
        color: dataStyle.color.withOpacity(1.0),
        fontFeatures: [FontFeature.tabularFigures()]);
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Row(children: [
        Expanded(
          child: Text(summary.drill.drill,
              textAlign: TextAlign.center, style: dataStyle),
        ),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _firstColumn(labelStyle: labelStyle, dataStyle: dataStyle),
        _secondColumn(labelStyle: labelStyle, dataStyle: dataStyle),
      ]),
    ]);
  }

  Widget _padBelow(Text text) {
    return Padding(padding: EdgeInsets.only(bottom: 16), child: text);
  }

  Widget _firstColumn({TextStyle labelStyle, TextStyle dataStyle}) {
    final successText = summary.good ?? '--';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Reps', style: labelStyle),
        _padBelow(Text('${summary.reps}', style: dataStyle)),
        Text('Success', style: labelStyle),
        Text('$successText', style: dataStyle),
      ],
    );
  }

  Widget _secondColumn({TextStyle labelStyle, TextStyle dataStyle}) {
    final durationText = DurationFormatter.format(
        Duration(seconds: summary.drill.elapsedSeconds));
    final accuracyText = PercentFormatter.formatAccuracy(
        trackedReps: summary.reps, trackedGood: summary.good);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Duration', style: labelStyle),
        _padBelow(Text('$durationText', style: dataStyle)),
        Text('Accuracy', style: labelStyle),
        Text('$accuracyText', style: dataStyle),
      ],
    );
  }
}
