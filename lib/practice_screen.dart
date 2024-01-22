/// Displays the active practice screen. Note that the app might be suspended
/// while practice is in progress, so the actual logic of the practice session
/// is in PracticeBackground.
import 'package:flutter/material.dart';

import 'app_rater.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'practice_background.dart';
import 'results_screen.dart';
import 'practice_status_widget.dart';
import 'screenshot_data.dart';
import 'simple_dialog_item.dart';
import 'spinner.dart';
import 'static_drills.dart';
import 'tracking_dialog.dart';
import 'tracking_info.dart';

final _log = Log.get('PracticeScreen');

class PracticeScreen extends StatefulWidget {
  static const routeName = '/practice';

  static void pushNamed(BuildContext context) {
    Navigator.pushNamed(context, PracticeScreen.routeName);
  }

  final StaticDrills staticDrills;
  final AppRater appRater;
  final PracticeBackground practice;

  PracticeScreen(
      {Key? key,
      required this.staticDrills,
      required this.appRater,
      required this.practice})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PracticeScreenState();
  }
}

// State transitions here are tricky:
// - the in-app stop button (goes to results screen)
// - the media controls stop button (goes to results screen)
// - the in-app back button (requests confirmation for cancel)
// - the phone back button (requests confirmation for cancel)
//
// The within-practice state is also subtle, e.g. PracticeProgress can be
// delivered multiple times for the same action, so we have to be careful to
// not ask the user to confirm the action results more than once.
class _PracticeScreenState extends State<PracticeScreen> {
  // True if we're already leaving this widget.
  bool _popInProgress = false;
  // Sequence number for the last rendered action confirmation.
  int _lastRenderedConfirm = 0;
  late final Stream<PracticeProgress> _progressStream;

  @override
  void initState() {
    if (ScreenshotData.progress == null) {
      // Normal flow.
      _progressStream = widget.practice.progressStream;
      _log.info('BEE Using real progress stream $_progressStream');
    } else {
      // Override the practice screen for screenshots.
      _progressStream = Stream.fromIterable([ScreenshotData.progress!]);
      _log.info('BEE Using fake progress stream $_progressStream');
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
        appBar: MyAppBar(title: 'Practice', appRater: widget.appRater)
            .build(context),
        body: Spinner());
  }

  Widget _buildSnapshot(
      BuildContext context, AsyncSnapshot<PracticeProgress> snapshot) {
    _log.info('BEE rebuilding practice screen with ${snapshot.data}');
    if (snapshot.hasError) {
      return Scaffold(
          appBar: MyAppBar(title: 'Practice', appRater: widget.appRater)
              .build(context),
          body: Text('Error: ${snapshot.error}'));
    }
    if (snapshot.data == null) {
      return _loadingWidget(context);
    }
    final progress = snapshot.data!;
    if (progress.practiceState == PracticeState.stopped) {
      // Drill was stopped via notification media controls.
      _log.info('BEE drill stopped via notification media');
      WidgetsBinding.instance.addPostFrameCallback((_) => _onStop());
      return Scaffold();
    }
    if (progress.drill == null) {
      return _loadingWidget(context);
    }
    // StreamBuilder will redeliver progress messages, but we only
    // want to show the dialog once per shot.
    if (progress.confirm > this._lastRenderedConfirm) {
      this._lastRenderedConfirm = progress.confirm;
      Future.delayed(
          Duration.zero, () => _showTrackingDialog(context, progress));
    }
    return Scaffold(
      appBar: MyAppBar.drillTitle(
              drillData: progress.drill, appRater: widget.appRater)
          .build(context),
      body: PracticeStatusWidget(
          staticDrills: widget.staticDrills,
          progress: progress,
          practice: widget.practice,
          onStop: _onStop),
    );
  }

  // Stop the audio service on navigation away from this screen. This is only
  // invoked by in-app user navigation. This is triggered by:
  // - the phone back button
  // - the in-app back button.
  Future<bool> _onBackPressed(BuildContext context) async {
    _log.info('BEE Phone back button pressed');
    bool shouldResume = false;
    if (widget.practice.practicing) {
      widget.practice.pause();
      shouldResume = true;
    }
    bool? allowBack = await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Cancel Drill'),
        children: <Widget>[
          SimpleDialogItem(
              text: 'Continue',
              icon: Icons.play_arrow,
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                Navigator.pop(context, false);
              }),
          SimpleDialogItem(
            text: 'Stop',
            icon: Icons.clear,
            color: Theme.of(context).unselectedWidgetColor,
            onPressed: () async {
              await widget.practice.stopPractice();
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
      widget.practice.play();
    }
    if (allowBack) {
      _popInProgress = true;
    }
    return allowBack;
  }

  void _onStop() async {
    if (_popInProgress) {
      _log.info('BEE _onStop reentry');
      return;
    }
    _log.info('BEE _onStop invoked, switching screens');
    _popInProgress = true;
    // Should we have a confirmation dialog when practice is stopped?
    await widget.practice.stopPractice();
    _log.info('Stopped practice');
    if (widget.practice.lastActiveState?.results?.drill.id != null &&
        widget.practice.lastActiveState?.drill != null &&
        widget.practice.reps > 0) {
      ResultsScreen.pushReplacement(
          context,
          widget.practice.lastActiveState!.results!.drill.id!,
          widget.practice.lastActiveState!.drill!);
    } else {
      // Early stop to drill, before drill id is set. Go back to config screen.
      Navigator.pop(context);
    }
  }

  // Consider replacing this with a dialog that flexes depending on screen
  // orientation, using a column in portrait mode, and a row in landscape mode.
  void _showTrackingDialog(
      BuildContext context, PracticeProgress progress) async {
    // Sometimes we stop after the drill has reached time. For that
    // case, wait for an explicit 'play' action from the user instead
    // of automatically resuming.
    bool shouldResume = !_pausedForTime(progress);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return TrackingDialog(callback: (TrackingResult result) {
            _finishTracking(context, result, shouldResume);
          });
        });
  }

  static bool _pausedForTime(PracticeProgress progress) {
    Duration planned = Duration(minutes: progress.drill?.practiceMinutes ?? 0);
    if (planned.inSeconds == 0) {
      return false;
    }
    Duration? elapsed = progress.results?.drill.elapsed;
    return elapsed != null && elapsed.inSeconds == planned.inSeconds;
  }

  void _finishTracking(
      BuildContext context, TrackingResult result, bool shouldResume) {
    widget.practice.trackResult(result);
    Navigator.pop(context);
    if (shouldResume) {
      widget.practice.play();
    }
  }
}
