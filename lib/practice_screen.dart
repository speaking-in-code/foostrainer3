import 'dart:convert';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';

/// Widget to display list of drills.
import 'package:flutter/material.dart';

import 'drill_data.dart';
import 'keys.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'practice_background.dart';
import 'results_entities.dart';
import 'results_screen.dart';
import 'results_widget.dart';
import 'screenshot_data.dart';
import 'spinner.dart';
import 'static_drills.dart';
import 'tracking_info.dart';

final _log = Log.get('PracticeScreen');

class PracticeScreen extends StatefulWidget {
  static const repsKey = Key(Keys.repsKey);
  static const elapsedKey = Key(Keys.elapsedKey);
  static const routeName = '/practice';

  static void pushNamed(BuildContext context) {
    Navigator.pushNamed(context, PracticeScreen.routeName);
  }

  final StaticDrills staticDrills;

  PracticeScreen({Key key, @required this.staticDrills}) : super(key: key);

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
  static const pauseKey = Key(Keys.pauseKey);
  static const playKey = Key(Keys.playKey);
  // True if we're already leaving this widget.
  bool _popInProgress = false;
  int _lastRenderedConfirm = 0;
  bool _pauseForDrillComplete = false;
  PracticeState _practiceState = PracticeState.stopped;
  Stream<PracticeProgress> _progressStream;
  PracticeProgress _progress;

  @override
  void initState() {
    if (ScreenshotData.progress == null) {
      // Normal flow.
      _progressStream = PracticeBackground.progressStream;
    } else {
      // Override the practice screen for screenshots.
      _progressStream = Stream.fromIterable([ScreenshotData.progress]);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: StreamBuilder<PracticeProgress>(
            stream: _progressStream, builder: _buildSnapshot));
  }

  Widget _loadingWidget(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(title: 'Practice').build(context), body: Spinner());
  }

  Widget _buildSnapshot(
      BuildContext context, AsyncSnapshot<PracticeProgress> snapshot) {
    if (snapshot.hasError) {
      return Scaffold(
          appBar: MyAppBar(title: 'Practice').build(context),
          body: Text('Error: ${snapshot.error}'));
    }
    if (!snapshot.hasData) {
      return _loadingWidget(context);
    }
    _progress = snapshot.data;
    if (_progress.practiceState == PracticeState.stopped) {
      // Drill was stopped via notification media controls.
      WidgetsBinding.instance.addPostFrameCallback((_) => _onStop());
      return Scaffold();
    }
    if (_progress.drill == null) {
      return _loadingWidget(context);
    }
    // Sometimes we stop after the drill has reached time. For that
    // case, wait for an explicit 'play' action from the user instead
    // of automatically resuming.
    _pauseForDrillComplete =
        Duration(minutes: _progress.drill.practiceMinutes).inSeconds ==
            _progress.results?.drill?.elapsedSeconds;
    _practiceState = _progress.practiceState;
    // StreamBuilder will redeliver progress messages, but we only
    // want to show the dialog once per shot.
    if (_progress.confirm > this._lastRenderedConfirm) {
      this._lastRenderedConfirm = _progress.confirm;
      Future.delayed(Duration.zero, () => _showTrackingDialog(context));
    }
    return Scaffold(
        appBar: MyAppBar(title: _progress.drill.name).build(context),
        body: ResultsWidget(
            staticDrills: widget.staticDrills, summary: _progress.results),
        bottomNavigationBar: _controlButtons(context, _progress));
  }

  BottomAppBar _controlButtons(
      BuildContext context, PracticeProgress progress) {
    final stopButton = ElevatedButton(
      child: Icon(Icons.stop),
      onPressed: _onStop,
    );
    final actionButton = _actionButton(progress);
    return BottomAppBar(
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      stopButton,
      actionButton,
    ]));
  }

  ButtonStyleButton _actionButton(PracticeProgress progress) {
    if (progress.practiceState == PracticeState.playing) {
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

  // Stop the audio service on navigation away from this screen. This is only
  // invoked by in-app user navigation. This is triggered by:
  // - the phone back button
  // - the in-app back button.
  Future<bool> _onBackPressed(BuildContext context) async {
    _log.info('Phone back button pressed');
    bool shouldResume = false;
    if (_practiceState == PracticeState.playing) {
      PracticeBackground.pause();
      shouldResume = true;
    }
    bool allowBack = await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Cancel Drill'),
        children: <Widget>[
          _SimpleDialogItem(
              text: 'Continue',
              icon: Icons.play_arrow,
              color: Theme.of(context).accentColor,
              onPressed: () {
                Navigator.pop(context, false);
              }),
          _SimpleDialogItem(
            text: 'Stop',
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
    allowBack ??= false;
    if (!allowBack && shouldResume) {
      // Clicked outside alert/did not respond. Keep going.
      PracticeBackground.play();
    }
    if (allowBack) {
      _popInProgress = true;
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
    _log.info('Stopped practice');
    int reps = _progress?.results?.reps ?? 0;
    if (reps > 0) {
      ResultsScreen.pushReplacement(
          context, _progress.results.drill.id, _progress.drill);
    } else {
      // Early stop to drill, before drill id is set. Go back to config screen.
      Navigator.pop(context);
    }
  }

  // Consider replacing this with a dialog that flexes depending on screen
  // orientation, using a column in portrait mode, and a row in landscape mode.
  void _showTrackingDialog(BuildContext context) async {
    final bool shouldResume = !_pauseForDrillComplete;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Enter Result'),
          children: <Widget>[
            _SimpleDialogItem(
              onPressed: () =>
                  _finishTracking(context, TrackingResult.GOOD, shouldResume),
              text: 'Good',
              icon: Icons.thumb_up,
              color: Theme.of(context).accentColor,
            ),
            _SimpleDialogItem(
              onPressed: () =>
                  _finishTracking(context, TrackingResult.MISSED, shouldResume),
              text: 'Missed',
              icon: Icons.thumb_down,
              color: Theme.of(context).unselectedWidgetColor,
            ),
            _SimpleDialogItem(
              onPressed: () =>
                  _finishTracking(context, TrackingResult.SKIP, shouldResume),
              text: 'Skip',
              icon: Icons.double_arrow,
              color: Theme.of(context).primaryColor,
            ),
          ],
        );
      },
    );
  }

  void _finishTracking(
      BuildContext context, TrackingResult result, bool shouldResume) {
    AudioService.customAction(SetTrackingRequest.action,
        jsonEncode(SetTrackingRequest(trackingResult: result).toJson()));
    Navigator.pop(context);
    if (shouldResume) {
      PracticeBackground.play();
    }
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
    double iconSize = 48;
    TextStyle textStyle = Theme.of(context).textTheme.headline6;
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: color),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16.0),
            child: Text(text, style: textStyle),
          ),
        ],
      ),
    );
  }
}
