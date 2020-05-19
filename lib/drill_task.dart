// Start a background isolate for executing drills.

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:sprintf/sprintf.dart';

import 'drill_data.dart';

class DrillProgress {
  static const String action = 'action';
  static const String shotCount = 'shotCount';
  static const String elapsedTime = 'elapsedTime';
  static const String drill = 'drill';

  /// Create a media item from the specified drill.
  static MediaItem fromDrillData(DrillData drillData) {
    return MediaItem(
        id: drillData.name,
        album: 'Time: 00:00:00, Reps: 0',
        title: drillData.name,
        extras: {
          action: '',
          shotCount: 0,
          elapsedTime: 0,
          drill: jsonEncode(drillData.toJson()),
        });
  }

  /// Get the drill from the provided media item.
  static DrillData fromMediaItem(MediaItem mediaItem) {
    var extras = mediaItem?.extras ?? {};
    String drillDataJson = extras[drill];
    if (drillDataJson == null) {
      throw StateError('MediaItem missing drill: ${mediaItem?.id}');
    }
    return DrillData.fromJson(jsonDecode(drillDataJson));
  }
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

MediaControl _playControl = MediaControl(
  androidIcon: 'drawable/ic_stat_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);

MediaControl _stopControl = MediaControl(
  androidIcon: 'drawable/ic_stat_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

class _DrillTask extends BackgroundAudioTask {
  static final _log = Logger();
  static final _rand = Random.secure();

  final _player = AudioPlayer();
  final _completer = Completer();
  final _stopwatch = Stopwatch();

  // onPlayMediaItem controlled
  MediaItem _mediaItem;
  DrillData _drillData;
  int _shotCount;
  String _lastElapsed;
  String _currentAction;

  // Pause/Play control
  Timer _shotTimer;
  Timer _durationTimer;

  _DrillTask();

  @override
  Future<void> onStart() {
    return _completer.future;
  }

  @override
  void onPlayMediaItem(MediaItem mediaItem) {
    _mediaItem = mediaItem;
    _drillData = DrillProgress.fromMediaItem(_mediaItem);
    _shotCount = 0;
    _lastElapsed = null;
    _stopwatch.reset();
    AudioServiceBackground.setState(
        controls: [_pauseControl, _stopControl],
        basicState: BasicPlaybackState.playing);
    onPlay();
  }

  @override
  void onPlay() {
    _stopwatch.start();
    // TODO: randomize timer based on action type and tuning.
    _shotTimer = Timer.periodic(Duration(seconds: 3), _playSomething);
    _durationTimer =
        Timer.periodic(Duration(milliseconds: 200), _updateDuration);
    AudioServiceBackground.setState(
        controls: [_pauseControl, _stopControl],
        basicState: BasicPlaybackState.playing);
    _currentAction = 'Waiting';
    _updateMediaItem();
  }

  @override
  void onPause() {
    _stopwatch.stop();
    AudioServiceBackground.setState(
        controls: [_playControl, _stopControl],
        basicState: BasicPlaybackState.paused);
    _shotTimer.cancel();
    _durationTimer.cancel();
    _currentAction = 'Paused';
    _updateMediaItem();
  }

  @override
  void onStop() {
    _log.i('Canceling timer');
    _stopwatch.reset();
    _shotTimer.cancel();
    _durationTimer.cancel();
    _player.stop();
    _completer.complete();
    _currentAction = 'Paused';
    _updateMediaItem();
    // TODO: figure out what else needs to happen in onStop.
  }

  void _playSomething(Timer timer) async {
    _log.i('Playing a sound');
    ++_shotCount;
    int actionIndex = _rand.nextInt(_drillData.actions.length);
    ActionData actionData = _drillData.actions[actionIndex];
    _currentAction = actionData.label;
    _updateMediaItem();
    await _player.setAsset(actionData.audioAsset);
    await _player.play();
    _currentAction = 'Waiting';
    _updateMediaItem();
  }

  void _updateDuration(Timer timer) async {
    _updateMediaItem();
  }

  void _updateMediaItem() async {
    String elapsed = _formatElapsed(_stopwatch.elapsed);
    // Calling this too frequently makes the notifications UI unresponsive, so
    // throttle to only cases where there is a visible change.
    if (elapsed == _lastElapsed) {
      return;
    }
    _log.i('Updating with elapsed time $elapsed');
    _lastElapsed = elapsed;
    _mediaItem.extras[DrillProgress.action] = _currentAction;
    _mediaItem.extras[DrillProgress.shotCount] = _shotCount;
    _mediaItem.extras[DrillProgress.elapsedTime] = elapsed;
    AudioServiceBackground.setMediaItem(_mediaItem);
  }

  String _formatElapsed(Duration elapsed) {
    int seconds = elapsed.inSeconds % 60;
    int minutes = elapsed.inMinutes % 60;
    int hours = elapsed.inHours ~/ 60;
    return sprintf('%02d:%02d:%02d', [hours, minutes, seconds]);
  }

}
