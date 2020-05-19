/// Widget to display list of drills.
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

import 'drill_data.dart';
import 'drill_task.dart';

class _ScreenState {
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  _ScreenState(this.mediaItem, this.playbackState);
}

class PracticeScreen extends StatelessWidget {
  static final log = Logger();
  static const routeName = '/practice';

  PracticeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: StreamBuilder<_ScreenState>(
            stream: _screenStateStream,
            builder: (context, snapshot) {
              if (snapshot?.data?.mediaItem == null) {
                log.i('no media item, returning empty scaffold');
                return Scaffold();
              }
              var drill = DrillProgress.fromMediaItem(snapshot.data.mediaItem);
              return Scaffold(
                  appBar: AppBar(title: Text('${drill.name}')),
                  body: _PracticeScreenProgress(
                      screenState: snapshot.data, drill: drill));
            }));
  }

  // Stop the audio service on navigation away from this screen.
  Future<bool> _onWillPop() async {
    AudioService.stop();
    return true;
  }

  // Combined stream of everything we need from the background audio task.
  Stream<_ScreenState> get _screenStateStream =>
      Rx.combineLatest2<MediaItem, PlaybackState, _ScreenState>(
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (mediaItem, playbackState) => _ScreenState(mediaItem, playbackState));
}

class _PracticeScreenProgress extends StatelessWidget {
  final _ScreenState screenState;
  final DrillData drill;

  _PracticeScreenProgress({Key key, this.screenState, this.drill})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String action = screenState.mediaItem.extras[DrillProgress.action];
    int shotCount = screenState.mediaItem.extras[DrillProgress.shotCount];
    String elapsed = screenState.mediaItem.extras[DrillProgress.elapsedTime];
    RaisedButton actionButton;
    if (screenState.playbackState.basicState != BasicPlaybackState.playing) {
      actionButton =
          RaisedButton(child: Icon(Icons.play_arrow), onPressed: _playPressed);
    } else {
      actionButton =
          RaisedButton(child: Icon(Icons.pause), onPressed: _pausePressed);
    }
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _data(context, '$action'),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_label(context, 'Reps'), _data(context, '$shotCount')],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_label(context, 'Time'), _data(context, '$elapsed')],
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

  void _pausePressed() {
    AudioService.pause();
  }

  void _playPressed() {
    AudioService.play();
  }
}
