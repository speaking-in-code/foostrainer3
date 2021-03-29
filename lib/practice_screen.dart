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
  int _lastRenderedConfirm = 0;

  Stream<PracticeProgress> _progressStream() {
    if (ScreenshotData.progress == null) {
      // Normal flow.
      return PracticeBackground.progressStream;
    } else {
      // Override the practice screen for screenshots.
      return Stream.fromIterable([ScreenshotData.progress]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Stream<PracticeProgress> stream = _progressStream();
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
              // StreamBuilder will redeliver progress messages, but we only
              // want to show the dialog once per shot.
              if (progress.confirm > this._lastRenderedConfirm) {
                _log.info('Queuing tracking dialog ${progress.action}');
                this._lastRenderedConfirm = progress.confirm;
                Future.delayed(
                    Duration.zero, () => _showTrackingDialog(context));
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

  void _showTrackingDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Enter Result'),
          children: <Widget>[
            _SimpleDialogItem(
              onPressed: () => _finishTracking(context, _TrackingResult.GOOD),
              text: 'Good',
              icon: Icons.thumb_up,
              color: Theme.of(context).accentColor,
            ),
            _SimpleDialogItem(
              onPressed: () => _finishTracking(context, _TrackingResult.MISSED),
              text: 'Missed',
              icon: Icons.thumb_down,
              color: Theme.of(context).unselectedWidgetColor,
            ),
            _SimpleDialogItem(
              onPressed: () => _finishTracking(context, _TrackingResult.SKIP),
              text: 'Skip',
              icon: Icons.double_arrow,
              color: Theme.of(context).primaryColor,
            ),
          ],
        );
      },
    );
  }

  void _finishTracking(BuildContext context, _TrackingResult result) {
    Navigator.pop(context);
    PracticeBackground.play();
  }
}

enum _TrackingResult {
  GOOD,
  MISSED,
  SKIP,
}

// Copied from https://material.io/components/dialogs/flutter#simple-dialog.
class _SimpleDialogItem extends StatelessWidget {
  const _SimpleDialogItem(
      {Key key, this.icon, this.color, this.text, this.onPressed})
      : super(key: key);

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 36.0, color: color),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16.0),
            child: Text(text),
          ),
        ],
      ),
    );
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
    ElevatedButton actionButton;
    if (progress.state == PracticeState.playing) {
      actionButton = ElevatedButton(
          key: pauseKey,
          child: Icon(Icons.pause),
          onPressed: PracticeBackground.pause);
    } else {
      actionButton = ElevatedButton(
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
