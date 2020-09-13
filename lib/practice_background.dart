// Start a background isolate for executing drills.

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import 'drill_data.dart';
import 'duration_formatter.dart';
import 'log.dart';

final _log = Log.get('PracticeBackground');

/// Methods to manage the practice background task.
class PracticeBackground {
  static const _action = 'action';
  static const _shotCount = 'shotCount';
  static const _elapsed = 'elapsed';
  static const _drill = 'drill';

  /// Start practicing the provided drill.
  static Future<void> startPractice(DrillData drill) async {
    await AudioService.start(
        backgroundTaskEntrypoint: _startBackgroundTask,
        androidNotificationChannelName: 'FoosTrainerNotificationChannel',
        androidNotificationIcon: 'drawable/ic_stat_ic_notification',
        androidNotificationColor: Colors.blueAccent.value);
    if (AudioService.running) {
      var progress = PracticeProgress(
          drill: drill,
          state: PracticeState.paused,
          elapsed: DurationFormatter.zero,
          action: '',
          shotCount: 0);
      AudioService.playMediaItem(getMediaItemFromProgress(progress));
    } else {
      throw StateError('Failed to start AudioService.');
    }
  }

  // True if the audio service is running in the background.
  static get running => AudioService.running;

  /// Pause the drill.
  static pause() {
    AudioService.pause();
  }

  /// Play the drill.
  static play() {
    AudioService.play();
  }

  /// Get a stream of progress updates.
  static Stream<PracticeProgress> get progressStream =>
      Rx.combineLatest2<MediaItem, PlaybackState, PracticeProgress>(
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (mediaItem, playbackState) =>
              _transformBackgroundUpdate(mediaItem, playbackState));

  /// Stop practice.
  static Future<void> stopPractice() async {
    AudioService.stop();
    return true;
  }

  /// Get a progress report from a MediaItem update.
  static PracticeProgress _transformBackgroundUpdate(
      MediaItem mediaItem, PlaybackState playbackState) {
    var extras = mediaItem?.extras ?? {};
    String drillDataJson = extras[_drill];
    if (drillDataJson == null) {
      throw StateError('MediaItem missing drill: ${mediaItem?.id}');
    }
    PracticeState state = PracticeState.paused;
    if (playbackState?.playing ?? false) {
      state = PracticeState.playing;
    }
    return PracticeProgress(
        drill: DrillData.fromJson(jsonDecode(extras[_drill])),
        state: state,
        action: extras[_action],
        shotCount: extras[_shotCount],
        elapsed: extras[_elapsed]);
  }

  /// Get a media item from the specified progress.
  static MediaItem getMediaItemFromProgress(PracticeProgress progress) {
    return MediaItem(
        id: progress.drill.name,
        title: 'Time: ${progress.elapsed}, Reps: ${progress.shotCount}',
        album: progress.drill.name,
        artist: 'FoosTrainer',
        extras: {
          _action: progress.action,
          _shotCount: progress.shotCount,
          _elapsed: progress.elapsed,
          _drill: jsonEncode(progress.drill.toJson()),
        });
  }
}

void _startBackgroundTask() {
  AudioServiceBackground.run(() => _BackgroundTask());
}

enum PracticeState {
  paused,
  playing,
  stopped,
}

/// Current state of practice.
class PracticeProgress {
  DrillData drill;
  PracticeState state;
  String action;
  int shotCount;
  String elapsed;

  PracticeProgress(
      {@required this.drill,
      @required this.state,
      @required this.action,
      @required this.shotCount,
      @required this.elapsed});

  factory PracticeProgress.empty() {
    return PracticeProgress(
        drill: null,
        state: PracticeState.stopped,
        action: 'Loading',
        shotCount: 0,
        elapsed: DurationFormatter.zero);
  }
}

const MediaControl _pauseControl = MediaControl(
  androidIcon: 'drawable/ic_stat_pause',
  label: 'Pause',
  action: MediaAction.pause,
);

const MediaControl _playControl = MediaControl(
  androidIcon: 'drawable/ic_stat_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);

const MediaControl _stopControl = MediaControl(
  androidIcon: 'drawable/ic_stat_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

class _BackgroundTask extends BackgroundAudioTask {
  static const _startEvent = 'ft_start_practice';
  static const _stopEvent = 'ft_stop_practice';
  static const _pauseEvent = 'ft_pause_practice';
  static const _playEvent = 'ft_play_practice';
  static const _elapsedSeconds = 'elapsed_seconds';
  static const _drillType = 'drill_type';
  static const _drillName = 'drill_name';
  static const _setupTime = Duration(seconds: 3);

  static final _analytics = FirebaseAnalytics();
  static final _rand = Random.secure();

  final _player = AudioPlayer();
  final _stopwatch = Stopwatch();

  PracticeProgress _progress = PracticeProgress.empty();
  Timer _elapsedTimeUpdater;

  _BackgroundTask() {
    _log.info('Creating player');
  }

  void _logEvent(String name) {
    _analytics.logEvent(name: name, parameters: {
      _drillType: _progress?.drill?.type ?? '',
      _drillName: _progress?.drill?.name ?? '',
      _elapsedSeconds: _stopwatch.elapsed.inSeconds,
    });
  }

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
  }

  @override
  Future<void> onPlayMediaItem(MediaItem mediaItem) {
    _progress = PracticeBackground._transformBackgroundUpdate(mediaItem, null);
    _stopwatch.reset();
    _logEvent(_startEvent);
    return onPlay();
  }

  @override
  Future<void> onPlay() async {
    _logEvent(_playEvent);
    _progress.state = PracticeState.playing;
    await AudioServiceBackground.setState(
        controls: [_pauseControl, _stopControl],
        playing: true,
        processingState: AudioProcessingState.ready);
    _stopwatch.start();
    Timer.run(_waitForSetup);
    _elapsedTimeUpdater =
        Timer.periodic(Duration(milliseconds: 200), _updateElapsed);
  }

  @override
  Future<void> onPause() async {
    _logEvent(_pauseEvent);
    _progress.state = PracticeState.paused;
    _stopwatch.stop();
    _elapsedTimeUpdater.cancel();
    _progress.action = 'Paused';
    _updateMediaItem();
    await AudioServiceBackground.setState(
        controls: [_playControl, _stopControl],
        playing: false,
        processingState: AudioProcessingState.ready);
  }

  @override
  Future<void> onStop() async {
    _log.info('Stopping player');
    _logEvent(_stopEvent);
    _progress.state = PracticeState.stopped;
    _stopwatch?.reset();
    _elapsedTimeUpdater?.cancel();
    await _player.stop();
    await _player.dispose();
    await AudioServiceBackground.setState(
        controls: [],
        playing: false,
        processingState: AudioProcessingState.none);
    await super.onStop();
  }

  // Plays audio until complete.
  Future<void> _playUntilDone() async {
    // Pause first, since otherwise play() might return immediately.
    await _player.pause();
    return _player.play();
  }

  void _waitForSetup() async {
    if (_progress.state != PracticeState.playing) {
      return;
    }
    _progress.action = 'Setup';
    _updateMediaItem();
    await _player.setAsset('assets/cowbell.mp3');
    await _playUntilDone();
    _pause(_setupTime).whenComplete(_waitForAction);
  }

  void _waitForAction() async {
    if (_progress.state != PracticeState.playing) {
      return;
    }
    _progress.action = 'Wait';
    _updateMediaItem();
    final Duration max =
        Duration(seconds: _progress.drill.maxSeconds) - _setupTime;
    Duration waitTime;
    if (!max.isNegative) {
      waitTime = Duration(milliseconds: _rand.nextInt(max.inMilliseconds));
    } else {
      waitTime = Duration.zero;
    }
    _pause(waitTime).whenComplete(_playAction);
  }

  void _playAction() async {
    if (_progress.state != PracticeState.playing) {
      return;
    }
    ++_progress.shotCount;
    int actionIndex = _rand.nextInt(_progress.drill.actions.length);
    ActionData actionData = _progress.drill.actions[actionIndex];
    _progress.action = actionData.label;
    _updateMediaItem();
    await _player.setAsset(actionData.audioAsset);
    await _playUntilDone();
    _pause(Duration(seconds: 1)).whenComplete(_waitForSetup);
  }

  // Calling this too frequently makes the notifications UI unresponsive, so
  // throttle to only cases where there is a visible change.
  void _updateElapsed(Timer timer) async {
    if (_progress.state != PracticeState.playing) {
      return;
    }
    String elapsed = DurationFormatter.format(_stopwatch.elapsed);
    if (elapsed == _progress.elapsed) {
      return;
    }
    _updateMediaItem();
  }

  Future<void> _updateMediaItem() async {
    _progress.elapsed = DurationFormatter.format(_stopwatch.elapsed);
    await AudioServiceBackground.setMediaItem(
        PracticeBackground.getMediaItemFromProgress(_progress));
  }

  // Dart async methods are not entirely reliable in this isolate, see
  // https://github.com/ryanheise/audio_service/issues/458. Anything that relies
  // on scheduling future work is problematic.
  //
  // The work around: play a clip of silence for the desired duration. If you
  // imagine that we're playing the Final Jeopardy Theme, this seems cool. If
  // you realize that we're playing *nothing*, it's more of a hack.
  Future<void> _pause(Duration length) async {
    if (_progress.state != PracticeState.playing) {
      return;
    }
    const Duration start = Duration(seconds: 0);
    final Duration loaded = await _player.setAsset('assets/silence_30s.mp3');
    if (loaded.inMilliseconds < length.inMilliseconds) {
      throw Exception('Requested duration $length, max $loaded');
    }
    await _player.setClip(start: start, end: length);
    await _playUntilDone();
  }
}
