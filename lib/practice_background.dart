// Start a background isolate for executing drills.

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:wakelock_plus/wakelock_plus.dart';

import 'album_art.dart';
import 'debug_info.dart';
import 'drill_data.dart';
import 'duration_formatter.dart';
import 'log.dart';
import 'pause_timer.dart';
import 'random_delay.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'tracking_info.dart';

final _log = Log.get('PracticeBackground');

/// Methods to manage the practice background task.
class PracticeBackground {
  static const _action = 'action';
  static const _results = 'results';
  static const _drill = 'drill';
  static const _confirm = 'confirm';
  static const _practiceState = 'practiceState';

  final _PracticeHandler _handler;
  PracticeProgress? _latestState;

  static Future<PracticeBackground> init() async {
    _log.info('Initializing AudioService');
    final handler = await AudioService.init(
      builder: () => _PracticeHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelName: 'FoosTrainerNotificationChannel',
        androidNotificationIcon: 'drawable/ic_stat_ic_notification',
        notificationColor: Colors.blueAccent,
      ),
    );
    _log.info('AudioService initialization complete');
    return PracticeBackground._(handler);
  }

  PracticeBackground._(this._handler);

  /// Start practicing the provided drill.
  Future<void> startPractice(DrillData drill) async {
    if (drill.signal == Signal.AUDIO_AND_FLASH) {
      WakelockPlus.enable();
    }
    bool tracking = drill.tracking ?? false;
    final progress = PracticeProgress()
      ..drill = drill
      ..results = DrillSummary(
          drill: StoredDrill(
              startSeconds: DateTime.now().millisecondsSinceEpoch ~/ 1000,
              drill: drill.fullName,
              tracking: tracking,
              elapsedSeconds: 0),
          reps: 0,
          good: (tracking ? 0 : null),
          actions: {})
      ..practiceState = PracticeState.paused
      ..action = ''
      ..confirm = 0;
    _log.info('Playing with drill ${progress.drill!.encode()}');
    _log.info('results.drill is ${progress.results!.drill}');
    _log.info('encoded is ${progress.results!.drill.encode()}');
    _log.info('Playing with results ${progress.results!.encode()}');
    _handler.playMediaItem(getMediaItemFromProgress(progress));
  }

  /// Pause the drill.
  Future<void> pause() {
    return _handler.pause();
  }

  /// Play the drill.
  Future<void> play() {
    return _handler.play();
  }

  /// Whether practice is currently in progress.
  bool get running {
    return _latestState != null &&
        _latestState!.practiceState != PracticeState.stopped;
  }

  /// Get a stream of progress updates.
  Stream<PracticeProgress> get progressStream =>
      _handler.mediaItem.map((mediaItem) {
        PracticeProgress progress = _transformBackgroundUpdate(mediaItem);
        _latestState = progress;
        return progress;
      });

  /// Stop practice.
  Future<void> stopPractice() async {
    WakelockPlus.disable();
    await _handler.stop();
    // await progressStream.close();
  }

  /// Record tracking result
  Future<void> trackResult(TrackingResult result) async {
    await _handler.customAction(SetTrackingRequest.action,
        {SetTrackingRequest.result: result});
    return;
  }

  /// Get a progress report from a MediaItem update.
  static PracticeProgress _transformBackgroundUpdate(MediaItem? mediaItem) {
    _log.info('Background update: mediaItem=$mediaItem');
    if (mediaItem == null) {
      return PracticeProgress()..practiceState = PracticeState.stopped;
    }
    return _mediaToProgress(mediaItem);
  }

  static PracticeProgress _mediaToProgress(MediaItem mediaItem) {
    var extras = mediaItem.extras ?? {};
    String? drillDataJson = extras[_drill];
    if (drillDataJson == null) {
      throw StateError('MediaItem missing drill: ${mediaItem.id}');
    }
    return PracticeProgress()
      ..drill = DrillData.decode(extras[_drill])
      ..practiceState = PracticeState.values[extras[_practiceState]]
      ..action = extras[_action]
      ..results = DrillSummary.decode(extras[_results])
      ..confirm = (extras[_confirm] ?? 0);
  }

  /// Get a media item from the specified progress.
  static MediaItem getMediaItemFromProgress(PracticeProgress progress) {
    final timeStr = DurationFormatter.format(
        Duration(seconds: progress.results!.drill.elapsedSeconds));
    return MediaItem(
        id: progress.drill!.name,
        title: 'Time: $timeStr, Reps: ${progress.results!.reps}',
        album: progress.drill!.name,
        artist: 'FoosTrainer',
        artUri: AlbumArt.getUri(),
        extras: {
          _action: progress.action,
          _results: progress.results!.encode(),
          _drill: progress.drill!.encode(),
          _confirm: progress.confirm,
          _practiceState: progress.practiceState.index,
        });
  }
}

enum PracticeState {
  paused,
  playing,
  stopped,
}

/// Current state of practice.
class PracticeProgress {
  DrillData? drill;
  PracticeState practiceState = PracticeState.stopped;
  String? action;
  String? lastAction;
  DrillSummary? results;

  // The shot count to confirm. Flutter stream-based widget rendering will
  // sometimes redeliver rendering states, so we use this as a sequence number
  // to avoid repeating the same confirmation.
  int confirm = 0;

  String toString() =>
      'practiceState: $practiceState drill: $drill action: $action ' +
      'lastAction: $lastAction results: $results confirm $confirm';
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

class _PracticeHandler extends BaseAudioHandler {
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

  static final _analytics = FirebaseAnalytics.instance;
  static final _rand = Random.secure();

  final AudioPlayer _player;
  final PauseTimer _pauseTimer;
  final _stopwatch = Stopwatch();
  final Future<ResultsDatabase> _resultsDatabase;

  PracticeProgress _progress = PracticeProgress();
  Timer? _elapsedTimeUpdater;
  late RandomDelay _randomDelay;

  // Stop time for the drill. zero means play forever.
  Duration? _finishTime;

  factory _PracticeHandler() {
    _log.info('Creating player');
    final player = AudioPlayer();
    return _PracticeHandler._(player);
  }

  _PracticeHandler._(this._player)
      : _pauseTimer = PauseTimer(_player),
        _resultsDatabase = ResultsDatabase.init() {
    _log.info('Finished creating player');
  }

  void _logEvent(String name) {
    _analytics.logEvent(name: name, parameters: {
      _drillType: _progress.drill?.type ?? '',
      _drillName: _progress.drill?.fullName ?? '',
      _elapsedSeconds: _stopwatch.elapsed.inSeconds,
    });
  }

  @override
  Future<void> prepare() async {
    _log.info('prepare called');
    Future<void> artLoading = AlbumArt.load();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    await artLoading;
    _log.info('Finished prepare');
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    _log.info('playMediaItem called $mediaItem');
    _progress = PracticeBackground._mediaToProgress(mediaItem);
    final drillId = await (await _resultsDatabase)
        .drillsDao
        .insertDrill(_progress.results!.drill);
    _progress.results = _progress.results!
        .copyWith(drill: _progress.results!.drill.copyWith(id: drillId));
    _randomDelay = RandomDelay(
        min: _setupTime,
        max: Duration(seconds: _progress.drill!.possessionSeconds),
        tempo: _progress.drill!.tempo!);
    _finishTime = Duration(minutes: _progress.drill!.practiceMinutes!);
    _stopwatch.reset();
    _logEvent(_startEvent);
    return play();
  }

  @override
  Future<void> play() async {
    _log.info('play starts');
    _logEvent(_playEvent);
    _progress.practiceState = PracticeState.playing;
    playbackState.add(PlaybackState(
        controls: [_pauseControl, _stopControl],
        playing: true,
        processingState: AudioProcessingState.ready));
    _stopwatch.start();
    _progress.action = 'Setup';
    _updateMediaItem();
    _pause(_resetTime).whenComplete(_waitForSetup);
    _elapsedTimeUpdater =
        Timer.periodic(Duration(milliseconds: 200), _updateElapsed);
    _log.info('play done');
  }

  @override
  Future<void> pause() async {
    _logEvent(_pauseEvent);
    _progress.practiceState = PracticeState.paused;
    _stopwatch.stop();
    _elapsedTimeUpdater!.cancel();
    _progress.action = 'Paused';
    _updateMediaItem();
    playbackState.add(PlaybackState(
        controls: [_playControl, _stopControl],
        playing: false,
        processingState: AudioProcessingState.ready));
  }

  @override
  Future<void> stop() async {
    _log.info('Stopping player');
    _logEvent(_stopEvent);
    _progress.practiceState = PracticeState.stopped;
    _stopwatch.stop();
    _elapsedTimeUpdater?.cancel();

    await _maybeWriteResults();

    _stopwatch.reset();
    await _player.stop();
    await super.stop();
    _log.info('Finished stopping player');
  }

  Future<void> _maybeWriteResults() async {
    if (_progress.results == null) {
      return;
    }
    _log.info('Writing results: ${_progress.results!.drill.encode()}');
    try {
      if (_progress.results!.reps > 0) {
        await (await _resultsDatabase)
            .drillsDao
            .insertDrill(_progress.results!.drill);
      } else {
        await (await _resultsDatabase)
            .drillsDao
            .removeDrill(_progress.results!.drill.id!);
      }
    } catch (e) {
      _log.info('Database write error: $e');
    }
    _log.info('Write complete');
  }

  // Plays audio until complete.
  Future<void> _playUntilDone(String asset) async {
    // Pause first, since otherwise play() might return immediately.
    try {
      await _player.stop();
      await _player.setAsset(asset);
      await _player.play();
    } catch (e, stack) {
      _log.warning('Unexpected exception $e: $stack', e, stack);
    }
  }

  void _waitForSetup() async {
    if (_progress.practiceState != PracticeState.playing) {
      return;
    }
    _progress.action = 'Setup';
    _updateMediaItem();
    await _playUntilDone('assets/cowbell.mp3');
    _pause(_setupTime).whenComplete(_waitForAction);
  }

  void _waitForAction() async {
    if (_progress.practiceState != PracticeState.playing) {
      return;
    }
    _progress.action = 'Wait';
    _updateMediaItem();
    _pause(_randomDelay.get() - _setupTime).whenComplete(_playAction);
  }

  void _playAction() async {
    if (_progress.practiceState != PracticeState.playing) {
      return;
    }
    int actionIndex = _rand.nextInt(_progress.drill!.actions.length);
    ActionData actionData = _progress.drill!.actions[actionIndex];
    _progress.action = actionData.label;
    _progress.lastAction = _progress.action;
    if (_progress.drill!.signal == Signal.AUDIO_AND_FLASH) {
      _flashTorch();
    }
    await _playUntilDone(actionData.audioAsset);
    if (_progress.drill!.tracking!) {
      _waitForTracking();
    } else {
      await (await _resultsDatabase).actionsDao.incrementAction(
          _progress.results!.drill.id!, _progress.action!, ActionUpdate.NONE);
      _progress.results = await (await _resultsDatabase)
          .summariesDao
          .loadDrill(await _resultsDatabase, _progress.results!.drill.id!);
      _updateMediaItem();
      _pause(_resetTime).whenComplete(_waitForSetup);
    }
  }

  void _waitForTracking() {
    ++_progress.confirm;
    pause();
  }

  Future<void> _flashTorch() async {
    //await TorchCompat.turnOn();
    await Future.delayed(_flashTime);
    //await TorchCompat.turnOff();
  }

  // Calling this too frequently makes the notifications UI unresponsive, so
  // throttle to only cases where there is a visible change.
  void _updateElapsed(Timer timer) async {
    if (_progress.practiceState != PracticeState.playing) {
      return;
    }
    // If practice time has completed, give a moment, then play the "finished"
    // sound and pause.
    if (_finishTime != Duration.zero && _stopwatch.elapsed > _finishTime!) {
      _pause(const Duration(seconds: 1)).whenComplete(_finishPractice);
      pause();
      return;
    }
    if (_stopwatch.elapsed.inSeconds ==
        _progress.results!.drill.elapsedSeconds) {
      return;
    }
    _updateMediaItem();
  }

  Future<void> _finishPractice() async {
    await _playUntilDone('assets/triple_cowbell.mp3');
    _finishTime = Duration.zero;
  }

  Future<void> _updateMediaItem() async {
    _progress.results = _progress.results!.copyWith(
        drill: _progress.results!.drill
            .copyWith(elapsedSeconds: _stopwatch.elapsed.inSeconds));
    final writeOp = (await _resultsDatabase)
        .drillsDao
        .insertDrill(_progress.results!.drill);
    mediaItem.add(PracticeBackground.getMediaItemFromProgress(_progress));
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
    if (_progress.practiceState != PracticeState.playing) {
      return;
    }
    return _pauseTimer.pause(length);
  }

  @override
  Future<dynamic> customAction(String name,
      [Map<String, dynamic>? extras]) async {
    switch (name) {
      case DebugInfo.action:
        return _handleDebugInfo();
      case SetTrackingRequest.action:
        return _handleSetTracking(extras!);
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

  void _handleSetTracking(Map<String, dynamic> extras) async {
    final trackingResult = extras[SetTrackingRequest.result];
    switch (trackingResult) {
      case TrackingResult.GOOD:
        await (await _resultsDatabase).actionsDao.incrementAction(
            _progress.results!.drill.id!,
            _progress.lastAction!,
            ActionUpdate.GOOD);
        break;
      case TrackingResult.MISSED:
        await (await _resultsDatabase).actionsDao.incrementAction(
            _progress.results!.drill.id!,
            _progress.lastAction!,
            ActionUpdate.MISSED);
        break;
      case TrackingResult.SKIP:
      case null:
        break;
    }
    _progress.results = await (await _resultsDatabase)
        .summariesDao
        .loadDrill((await _resultsDatabase), _progress.results!.drill.id!);
  }
}
