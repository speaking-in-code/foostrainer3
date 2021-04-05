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
import 'package:torch_compat/torch_compat.dart';
import 'package:wakelock/wakelock.dart';

import 'album_art.dart';
import 'debug_info.dart';
import 'drill_data.dart';
import 'duration_formatter.dart';
import 'log.dart';
import 'pause_timer.dart';
import 'random_delay.dart';
import 'results_db.dart';
import 'results_info.dart';
import 'tracking_info.dart';

final _log = Log.get('PracticeBackground');

/// Methods to manage the practice background task.
class PracticeBackground {
  static const _action = 'action';
  static const _results = 'results';
  static const _drill = 'drill';
  static const _confirm = 'confirm';

  /// Start practicing the provided drill.
  static Future<void> startPractice(DrillData drill) async {
    if (drill.signal == Signal.AUDIO_AND_FLASH) {
      Wakelock.enable();
    }
    await AudioService.start(
        backgroundTaskEntrypoint: _startBackgroundTask,
        androidNotificationChannelName: 'FoosTrainerNotificationChannel',
        androidNotificationIcon: 'drawable/ic_stat_ic_notification',
        androidNotificationColor: Colors.blueAccent.value);
    if (AudioService.running) {
      final progress = PracticeProgress()
        ..drill = drill
        ..results =
            ResultsInfo.newDrill(drill: drill.name, tracking: drill.tracking)
        ..state = PracticeState.paused
        ..action = ''
        ..confirm = 0;
      _log.info('Playing with drill ${progress.drill.encode()}');
      _log.info('Playing with results ${progress.results.encode()}');
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
    Wakelock.disable();
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
    return PracticeProgress()
      ..drill = DrillData.decode(extras[_drill])
      ..state = state
      ..action = extras[_action]
      ..results = ResultsInfo.decode(extras[_results])
      ..confirm = (extras[_confirm] ?? 0);
  }

  /// Get a media item from the specified progress.
  static MediaItem getMediaItemFromProgress(PracticeProgress progress) {
    final timeStr = DurationFormatter.format(
        Duration(seconds: progress.results.elapsedSeconds));
    return MediaItem(
        id: progress.drill.name,
        title: 'Time: $timeStr, Reps: ${progress.results.reps}',
        album: progress.drill.name,
        artist: 'FoosTrainer',
        artUri: AlbumArt.getUri(),
        extras: {
          _action: progress.action,
          _results: progress.results.encode(),
          _drill: progress.drill.encode(),
          _confirm: progress.confirm,
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
  PracticeState state = PracticeState.stopped;
  String action;
  ResultsInfo results;
  // The shot count to confirm. Flutter stream-based widget rendering will
  // sometimes redeliver rendering states, so we use this as a sequence number
  // to avoid repeating the same confirmation.
  int confirm = 0;
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

  // Time to retrieve ball (possession clock not active.)
  static const _resetTime = Duration(seconds: 3);

  // Time for setup (possession clock running.)
  static const _setupTime = Duration(seconds: 3);

  // Time for flash signal.
  static const _flashTime = Duration(milliseconds: 500);

  static final _analytics = FirebaseAnalytics();
  static final _rand = Random.secure();

  final AudioPlayer _player;
  final PauseTimer _pauseTimer;
  final _stopwatch = Stopwatch();
  ResultsDatabase _resultsDatabase;

  PracticeProgress _progress = PracticeProgress();
  Timer _elapsedTimeUpdater;
  RandomDelay _randomDelay;

  // Stop time for the drill. zero means play forever.
  Duration _finishTime;

  factory _BackgroundTask() {
    _log.info('Creating player');
    final player = AudioPlayer();
    final pauseTimer = PauseTimer(player: player);
    return _BackgroundTask._(player, pauseTimer);
  }

  _BackgroundTask._(this._player, this._pauseTimer);

  void _logEvent(String name) {
    _analytics.logEvent(name: name, parameters: {
      _drillType: _progress?.drill?.type ?? '',
      _drillName: _progress?.drill?.name ?? '',
      _elapsedSeconds: _stopwatch.elapsed.inSeconds,
    });
  }

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    Future<ResultsDatabase> db =
        $FloorResultsDatabase.databaseBuilder('results.db').build();
    Future<void> artLoading = AlbumArt.load();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    await artLoading;
    _resultsDatabase = await db;
  }

  @override
  Future<void> onPlayMediaItem(MediaItem mediaItem) async {
    _progress = PracticeBackground._transformBackgroundUpdate(mediaItem, null);
    _randomDelay = RandomDelay(
        min: _setupTime,
        max: Duration(seconds: _progress.drill.possessionSeconds),
        tempo: _progress.drill.tempo);
    _finishTime = Duration(minutes: _progress.drill.practiceMinutes);
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
    _progress.action = 'Setup';
    _updateMediaItem();
    _pause(_resetTime).whenComplete(_waitForSetup);
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
    _stopwatch?.stop();
    _elapsedTimeUpdater?.cancel();

    _log.info('Writing results: ${_progress.results.encode()}');
    await _resultsDatabase.resultsInfoDao.insertResults(_progress.results);
    _log.info('Write complete');

    _stopwatch?.reset();
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
    _pause(_randomDelay.get() - _setupTime).whenComplete(_playAction);
  }

  void _playAction() async {
    if (_progress.state != PracticeState.playing) {
      return;
    }
    int actionIndex = _rand.nextInt(_progress.drill.actions.length);
    ActionData actionData = _progress.drill.actions[actionIndex];
    _progress.action = actionData.label;
    if (_progress.drill.signal == Signal.AUDIO_AND_FLASH) {
      _flashTorch();
    }
    await _player.setAsset(actionData.audioAsset);
    await _playUntilDone();
    if (_progress.drill.tracking) {
      _waitForTracking();
    } else {
      ++_progress.results.reps;
      _updateMediaItem();
      _pause(_resetTime).whenComplete(_waitForSetup);
    }
  }

  void _waitForTracking() {
    ++_progress.confirm;
    onPause();
  }

  Future<void> _flashTorch() async {
    await TorchCompat.turnOn();
    await Future.delayed(_flashTime);
    await TorchCompat.turnOff();
  }

  // Calling this too frequently makes the notifications UI unresponsive, so
  // throttle to only cases where there is a visible change.
  void _updateElapsed(Timer timer) async {
    if (_progress.state != PracticeState.playing) {
      return;
    }
    // If practice time has completed, give a moment, then play the "finished"
    // sound and pause.
    if (_finishTime != Duration.zero && _stopwatch.elapsed > _finishTime) {
      _pause(const Duration(seconds: 1)).whenComplete(_finishPractice);
      onPause();
      return;
    }
    if (_stopwatch.elapsed.inSeconds == _progress.results.elapsedSeconds) {
      return;
    }
    _updateMediaItem();
  }

  Future<void> _finishPractice() async {
    await _player.setAsset('assets/triple_cowbell.mp3');
    await _playUntilDone();
    _finishTime = Duration.zero;
  }

  Future<void> _updateMediaItem() async {
    _log.info(
        'Updating media item: ${_progress.action}, confirm: ${_progress.confirm}');
    _progress.results.elapsedSeconds = _stopwatch.elapsed.inSeconds;
    _log.info('Writing result ${_progress.results.encode()}');
    final writeOp =
        _resultsDatabase.resultsInfoDao.insertResults(_progress.results);
    final MediaItem item =
        PracticeBackground.getMediaItemFromProgress(_progress);
    await AudioServiceBackground.setMediaItem(item);
    await writeOp;
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
    return _pauseTimer.pause(length);
  }

  @override
  Future<dynamic> onCustomAction(String name, dynamic arguments) async {
    switch (name) {
      case DebugInfo.action:
        return _handleDebugInfo();
      case SetTrackingRequest.action:
        return _handleSetTracking(arguments);
      default:
        break;
    }
    throw Exception('Unknown custom action $name');
  }

  String _handleDebugInfo() {
    final metrics = _pauseTimer.calculateDelayMetrics();
    final resp = DebugInfoResponse(
        meanDelayMillis: metrics.meanDelayMillis,
        stdDevDelayMillis: metrics.stdDevDelayMillis);
    return jsonEncode(resp.toJson());
  }

  void _handleSetTracking(String arguments) {
    final request = SetTrackingRequest.fromJson(jsonDecode(arguments));
    switch (request.trackingResult) {
      case TrackingResult.GOOD:
        ++_progress.results.reps;
        ++_progress.results.good;
        break;
      case TrackingResult.MISSED:
        ++_progress.results.reps;
        break;
      case TrackingResult.SKIP:
        break;
    }
  }
}
