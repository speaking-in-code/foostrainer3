// Widget to display results from a drill. Contains the drill type, reps,
// time, success count, and accuracy.abstract

import 'dart:ui';

import 'package:flutter/material.dart';

import 'duration_formatter.dart';
import 'log.dart';
import 'percent_formatter.dart';
import 'practice_background.dart';
import 'results_entities.dart';
import 'static_drills.dart';

final _log = Log.get('PracticeStatusWidget');

class PracticeStatusWidget extends StatelessWidget {
  static const repsKey = Key('PracticeStatusWidget.reps');
  static const elapsedKey = Key('PracticeStatusWidget.elapsed');
  static const accuracyKey = Key('PracticeStatusWidget.accuracy');

  final StaticDrills staticDrills;
  final PracticeProgress progress;
  final DrillSummary summary;
  final PracticeBackground practice;
  final VoidCallback onStop;

  PracticeStatusWidget(
      {Key? key,
      required this.staticDrills,
      required this.progress,
      required this.practice,
      required this.onStop})
      : summary = progress.results!,
        assert(progress.results != null);

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = Theme.of(context).textTheme.headlineSmall!;
    labelStyle =
        labelStyle.copyWith(color: labelStyle.color!.withOpacity(0.75));
    TextStyle dataStyle = Theme.of(context).textTheme.headlineMedium!;
    dataStyle = dataStyle.copyWith(
        color: dataStyle.color!.withOpacity(1.0),
        fontFeatures: [FontFeature.tabularFigures()]);
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return _buildPortrait(context, labelStyle, dataStyle);
    } else {
      return _buildLandscape(context, labelStyle, dataStyle);
    }
  }

  Widget _buildPortrait(
      BuildContext context, TextStyle labelStyle, TextStyle dataStyle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _currentAction(dataStyle),
        _infoGrid(context, labelStyle, dataStyle),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _stopButton(context),
          _actionButton(context),
        ])
      ],
    );
  }

  Widget _buildLandscape(
      BuildContext context, TextStyle labelStyle, TextStyle dataStyle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _currentAction(dataStyle),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _infoGrid(context, labelStyle, dataStyle),
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _padBelow(_actionButton(context)),
              _stopButton(context)
            ]),
          ],
        )
      ],
    );
  }

  Widget _currentAction(TextStyle dataStyle) {
    return Row(children: [
      Expanded(
        child: Text(
          progress.action!,
          textAlign: TextAlign.center,
          style: dataStyle,
        ),
      ),
    ]);
  }

  Widget _infoGrid(
      BuildContext context, TextStyle labelStyle, TextStyle dataStyle) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _firstColumn(labelStyle: labelStyle, dataStyle: dataStyle),
      _secondColumn(labelStyle: labelStyle, dataStyle: dataStyle),
    ]);
  }

  Widget _stopButton(BuildContext context) {
    return _fabButton(context, Icons.stop, () {
      _log.info('BEE stop button pushed');
      onStop();
    });
  }

  Widget _actionButton(BuildContext context) {
    if (progress.practiceState == PracticeState.playing) {
      return _fabButton(context, Icons.pause, () {
        _log.info('BEE pause button');
        practice.pause();
      });
    }
    return _fabButton(context, Icons.play_arrow, () {
      _log.info('BEE play button');
      practice.play();
    });
  }

  Widget _fabButton(
      BuildContext context, IconData iconData, VoidCallback onPressed) {
    return Ink(
        decoration: ShapeDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: CircleBorder(),
        ),
        child: IconButton(
            icon: Icon(iconData),
            onPressed: onPressed,
            color: Theme.of(context).colorScheme.onSecondary));
  }

  Widget _padBelow(Widget child) {
    return Padding(padding: EdgeInsets.only(bottom: 16), child: child);
  }

  Widget _firstColumn(
      {required TextStyle labelStyle, required TextStyle dataStyle}) {
    String successText = '--';
    if (summary.drill.tracking) {
      if (summary.good != null) {
        successText = '${summary.good}';
      } else {
        successText = '0';
      }
    }
    int reps = summary.reps;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Reps', style: labelStyle),
        _padBelow(Text('$reps', style: dataStyle, key: repsKey)),
        Text('Success', style: labelStyle),
        Text('$successText', style: dataStyle),
      ],
    );
  }

  Widget _secondColumn(
      {required TextStyle labelStyle, required TextStyle dataStyle}) {
    final durationText = DurationFormatter.format(
        Duration(seconds: summary.drill.elapsedSeconds));
    final accuracyText = PercentFormatter.formatAccuracy(
        trackedReps: summary.reps, trackedGood: summary.good);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Duration', style: labelStyle),
        _padBelow(Text('$durationText', style: dataStyle, key: elapsedKey)),
        Text('Accuracy', style: labelStyle),
        Text('$accuracyText', style: dataStyle, key: accuracyKey),
      ],
    );
  }
}
