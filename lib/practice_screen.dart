/// Widget to display list of drills.
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

import 'drill_data.dart';
import 'practice_background.dart';

class _ScreenState {
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  _ScreenState(this.mediaItem, this.playbackState);
}

class PracticeScreen extends StatelessWidget {
  static final log = Logger();
  static const routeName = '/practice';

  PracticeScreen({Key key}) : super(key: key);

  // Fix control of this screen from the notification bar.
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: StreamBuilder<PracticeProgress>(
            stream: PracticeBackground.progressStream,
            builder: (context, snapshot) {
              if (snapshot?.data == null) {
                return Scaffold();
              }
              var progress = snapshot.data;
              return Scaffold(
                  appBar: AppBar(title: Text('${progress.drill.name}')),
                  body: _PracticeScreenProgress(progress: progress));
            }));
  }

  // Stop the audio service on navigation away from this screen.
  Future<bool> _onWillPop() async {
    PracticeBackground.stopPractice();
    return true;
  }
}

class _PracticeScreenProgress extends StatelessWidget {
  final PracticeProgress progress;

  _PracticeScreenProgress({Key key, this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RaisedButton actionButton;
    if (progress.playing) {
      actionButton = RaisedButton(
          child: Icon(Icons.pause), onPressed: PracticeBackground.pause);
    } else {
      actionButton = RaisedButton(
          child: Icon(Icons.play_arrow), onPressed: PracticeBackground.play);
    }
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _data(context, '${progress.action}'),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _label(context, 'Reps'),
            _data(context, '${progress.shotCount}')
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _label(context, 'Time'),
            _data(context, '${progress.elapsed}')
          ],
        ),
      ]),
      actionButton
    ]);
  }

  Text _label(BuildContext context, String value) {
    return Text(value, style: Theme.of(context).textTheme.headline4);
  }

  Text _data(BuildContext context, String value) {
    return Text(value, style: Theme.of(context).textTheme.headline4);
  }
}
