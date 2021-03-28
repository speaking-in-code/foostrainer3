import 'dart:ui';

/// Widget to display list of drills.
import 'package:flutter/material.dart';

import 'keys.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'practice_background.dart';
import 'screenshot_data.dart';

final _log = Log.get('PracticeScreen');

class PracticeScreen extends StatefulWidget {
  static const repsKey = Key(Keys.repsKey);
  static const elapsedKey = Key(Keys.elapsedKey);
  static const routeName = '/practice';

  PracticeScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PracticeScreenState();
  }
}

class _PracticeScreenState extends State<PracticeScreen> {
  // True if we're already leaving this widget.
  bool _popInProgress = false;

  @override
  Widget build(BuildContext context) {
    var stream;
    if (ScreenshotData.progress == null) {
      // Normal flow.
      stream = PracticeBackground.progressStream;
    } else {
      // Override the practice screen for screenshots.
      stream = Stream.fromIterable([ScreenshotData.progress]);
    }
    return WillPopScope(
        onWillPop: _onWillPop,
        child: StreamBuilder<PracticeProgress>(
            stream: stream,
            initialData: ScreenshotData.progress,
            builder: (context, snapshot) {
              _log.info(
                  'PracticeBackground.running = ${PracticeBackground.running}');
              if (PracticeBackground.running != null &&
                  !PracticeBackground.running &&
                  ScreenshotData.progress == null) {
                // Drill was stopped via notification media controls.
                if (!_popInProgress) {
                  _popInProgress = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pop(context);
                  });
                }
                return Scaffold();
              }
              var progress = snapshot?.data;
              if (progress == null) {
                // Stream still being initialized, use the passed in drill to
                // speed up rendering.
                progress = PracticeProgress.empty();
                progress.drill = ModalRoute.of(context).settings.arguments;
              }
              return Scaffold(
                  appBar: MyAppBar(title: progress.drill.name).build(context),
                  body: _PracticeScreenProgress(progress: progress));
            }));
  }

  // Stop the audio service on navigation away from this screen. This is only
  // invoked by in-app user navigation.
  Future<bool> _onWillPop() async {
    _popInProgress = true;
    PracticeBackground.stopPractice();
    return true;
  }
}

class _PracticeScreenProgress extends StatelessWidget {
  static const pauseKey = Key(Keys.pauseKey);
  static const playKey = Key(Keys.playKey);
  static const kLargeFontMinWidth = 480;
  final PracticeProgress progress;

  _PracticeScreenProgress({Key key, this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RaisedButton actionButton;
    if (progress.state == PracticeState.playing) {
      actionButton = RaisedButton(
          key: pauseKey,
          child: Icon(Icons.pause),
          onPressed: PracticeBackground.pause);
    } else {
      actionButton = RaisedButton(
          key: playKey,
          child: Icon(Icons.play_arrow),
          onPressed: PracticeBackground.play);
    }
    final tabular = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);
    // Smaller devices in portrait orientation do better with a smaller font.
    final textStyle = MediaQuery.of(context).size.width > kLargeFontMinWidth
        ? Theme.of(context).textTheme.headline3
        : Theme.of(context).textTheme.headline4;
    return DefaultTextStyle(
        style: textStyle,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text('${progress.action}'),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Reps'),
                Text('${progress.shotCount}',
                    key: PracticeScreen.repsKey, style: tabular),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Time'),
                Text('${progress.elapsed}',
                    key: PracticeScreen.elapsedKey, style: tabular),
              ],
            ),
          ]),
          actionButton
        ]));
  }
}
