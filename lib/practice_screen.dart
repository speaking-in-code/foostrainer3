import 'dart:convert';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';

/// Widget to display list of drills.
import 'package:flutter/material.dart';
import 'package:ft3/results_screen.dart';
import 'package:ft3/tracking_info.dart';

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

// TODO(brian): work on state tracking/recording. Make sure that state is
// always initialized at drill start and finish.
// Navigation here is tricky. There are lots of ways to transition state.
// - the in-app stop button (goes to results screen)
// - the media controls stop button (goes to results screen)
// - the in-app back button (requests confirmation for cancel)
// - the phone back button (requests confirmation for cancel)
//
// I'm tempted, but not sure, about adding a confirmation for the stop step as
// well as the back step.
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
        onWillPop: () => _onBackPressed(context),
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
                WidgetsBinding.instance.addPostFrameCallback((_) => _onStop());
                return Scaffold();
              }
              var progress = snapshot?.data;
              if (progress == null) {
                // Stream still being initialized, use the passed in drill to
                // speed up rendering.
                progress = PracticeProgress()
                  ..drill = ModalRoute.of(context).settings.arguments;
              }
              // StreamBuilder will redeliver progress messages, but we only
              // want to show the dialog once per shot.
              if (progress.confirm > this._lastRenderedConfirm) {
                this._lastRenderedConfirm = progress.confirm;
                Future.delayed(
                    Duration.zero, () => _showTrackingDialog(context));
              }
              return Scaffold(
                  appBar: MyAppBar(title: progress.drill.name).build(context),
                  body: _PracticeScreenProgress(
                      progress: progress, onStop: _onStop));
            }));
  }

  // Stop the audio service on navigation away from this screen. This is only
  // invoked by in-app user navigation. This is triggered by:
  // - the phone back button
  // - the in-app back button.
  Future<bool> _onBackPressed(BuildContext context) async {
    _log.info('Phone back button pressed');
    PracticeBackground.pause();
    bool allowBack = await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Cancel Drill'),
        children: <Widget>[
          _SimpleDialogItem(
              text: 'Keep Practicing',
              icon: Icons.play_arrow,
              color: Theme.of(context).accentColor,
              onPressed: () {
                PracticeBackground.play();
                Navigator.pop(context, false);
              }),
          _SimpleDialogItem(
            text: 'Cancel',
            icon: Icons.clear,
            color: Theme.of(context).unselectedWidgetColor,
            onPressed: () async {
              await PracticeBackground.stopPractice();
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
    _log.info('Allowing back $allowBack');
    if (allowBack == null) {
      // Clicked outside alert/did not respond. Keep going.
      PracticeBackground.play();
      allowBack = false;
    }
    return allowBack;
  }

  void _onStop() async {
    if (_popInProgress) {
      _log.info('_onStop reentry');
      return;
    }
    _log.info('_onStop invoked, switching screens');
    _popInProgress = true;
    // Should we have a confirmation dialog when practice is stopped?
    await PracticeBackground.stopPractice();
    Navigator.pushReplacementNamed(context, ResultsScreen.routeName);
  }

  void _showTrackingDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Enter Result'),
          children: <Widget>[
            _SimpleDialogItem(
              onPressed: () => _finishTracking(context, TrackingResult.GOOD),
              text: 'Good',
              icon: Icons.thumb_up,
              color: Theme.of(context).accentColor,
            ),
            _SimpleDialogItem(
              onPressed: () => _finishTracking(context, TrackingResult.MISSED),
              text: 'Missed',
              icon: Icons.thumb_down,
              color: Theme.of(context).unselectedWidgetColor,
            ),
            _SimpleDialogItem(
              onPressed: () => _finishTracking(context, TrackingResult.SKIP),
              text: 'Skip',
              icon: Icons.double_arrow,
              color: Theme.of(context).primaryColor,
            ),
          ],
        );
      },
    );
  }

  void _finishTracking(BuildContext context, TrackingResult result) {
    AudioService.customAction(SetTrackingRequest.action,
        jsonEncode(SetTrackingRequest(trackingResult: result).toJson()));
    Navigator.pop(context);
    PracticeBackground.play();
  }
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
  final VoidCallback onStop;

  _PracticeScreenProgress({Key key, this.progress, this.onStop})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final actionButton = _actionButton();
    final stopButton = ElevatedButton(
      child: Icon(Icons.stop),
      onPressed: () => onStop(),
    );
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            stopButton,
            actionButton,
          ]),
        ]));
  }

  ElevatedButton _actionButton() {
    if (progress.state == PracticeState.playing) {
      return ElevatedButton(
          key: pauseKey,
          child: Icon(Icons.pause),
          onPressed: PracticeBackground.pause);
    }
    return ElevatedButton(
        key: playKey,
        child: Icon(Icons.play_arrow),
        onPressed: PracticeBackground.play);
  }
}
