// Start a background isolate for executing drills.

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:sprintf/sprintf.dart';

class DrillProgress {
  static final String kShotCount = "shotCount";
  static final String kElapsedTime = "elapsedTime";
}

void initDrillTask() async {
  Logger().i('Calling AndroidServiceBackground.run');
  AudioServiceBackground.run(() => _DrillTask());
}

MediaControl _pauseControl = MediaControl(
  androidIcon: 'drawable/ic_stat_pause',
  label: 'Pause',
  action: MediaAction.pause,
);

// MediaControl _playControl = MediaControl(
//  androidIcon: 'drawable/ic_stat_play_arrow',
//  label: 'Play',
//  action: MediaAction.play,
//);

MediaControl _stopControl = MediaControl(
  androidIcon: 'drawable/ic_stat_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

class _DrillTask extends BackgroundAudioTask {
  static final _logger = Logger();

  final _kAudioPath = 'assets/pass_bounce.mp3';
  final _player = AudioPlayer();
  final _completer = Completer();
  Timer _shotTimer;
  Timer _durationTimer;
  int _shotCount = 0;
  DateTime _startTime;
  String _lastElapsed;

  _DrillTask() {
    _logger.i('DrillTask is alive!');
  }

  @override
  Future<void> onStart() {
    _logger.i('Starting timer to run every 3 seconds');
    _shotTimer = Timer.periodic(Duration(seconds: 3), _playSomething);
    _durationTimer =
        Timer.periodic(Duration(milliseconds: 200), _updateDuration);
    _startTime = DateTime.now();
    _logger.i('Calling setState');
    AudioServiceBackground.setState(
        controls: [_pauseControl, _stopControl],
        basicState: BasicPlaybackState.playing);
    return _completer.future;
  }

  void _playSomething(Timer timer) async {
    _logger.i('Playing a sound');
    ++_shotCount;
    _updateMediaItem();
    await _player.setAsset(_kAudioPath);
    await _player.play();
  }

  void _updateDuration(Timer timer) async {
    _updateMediaItem();
  }

  void _updateMediaItem() async {
    DateTime current = DateTime.now();
    String elapsed = _formatElapsed(current.difference(_startTime));
    // Calling this too frequently makes the notifications UI unresponsive, so
    // throttle to only cases where there is a visible change.
    if (elapsed == _lastElapsed) {
      return;
    }
    _logger.i('Updating with elapsed time $elapsed');
    _lastElapsed = elapsed;
    AudioServiceBackground.setMediaItem(MediaItem(
      id: 'https://www.example.com/item',
      album: 'Time: $elapsed, Reps: $_shotCount',
      title: 'Stick Pass',
      extras: {
        DrillProgress.kShotCount: _shotCount,
        DrillProgress.kElapsedTime: elapsed
      }
    ));
  }

  String _formatElapsed(Duration elapsed) {
    int seconds = elapsed.inSeconds % 60;
    int minutes = elapsed.inMinutes % 60;
    int hours = elapsed.inHours ~/ 60;
    return sprintf('%02d:%02d:%02d', [hours, minutes, seconds]);
  }

  @override
  void onPause() {
    _logger.i('onPause called');
  }

  @override
  void onStop() {
    _logger.i('Canceling timer');
    _shotTimer.cancel();
    _durationTimer.cancel();
    _player.stop();
    _completer.complete();
  }
}
