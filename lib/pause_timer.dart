import 'dart:collection';

import 'package:just_audio/just_audio.dart';

import 'log.dart';

// Dart async methods are not entirely reliable in the background isolate, see
// https://github.com/ryanheise/audio_service/issues/458. Anything that relies
// on scheduling future work is problematic.
//
// The work around: play a clip of silence for the desired duration. If you
// imagine that we're playing the Final Jeopardy Theme, this seems cool. If
// you realize that we're playing *nothing*, it's more of a hack.
//
// Playing silence is less precise than Timers and delayed futures. Average
// additional latency is ~275 ms on an iPhone 5 with std dev of ~18 ms. However,
// that std dev number is misleading: it's not unusual to see a 750 ms delay if
// audio is not in cache. To work around the unpredictability, we use a delayed
// future for the final 2 seconds of each delay.
class PauseTimer {
  static const kDelayMemory = 100;
  static const kMinPlay = Duration(seconds: 2);
  static final _log = Log.get('PauseTimer');
  final ListQueue<int> _delays = ListQueue(kDelayMemory);
  final AudioPlayer _player;

  PauseTimer({AudioPlayer player}) : _player = player;

  Future<void> pause(final Duration length) async {
    final stopwatch = Stopwatch();
    stopwatch.start();
    if (length > kMinPlay) {
      await _pauseWithPlay(length - kMinPlay);
    }
    final remaining = length - stopwatch.elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
    stopwatch.stop();
    final over = stopwatch.elapsed - length;
    _log.info('Over time by ${over.inMilliseconds} ms');
  }

  Future<void> _pauseWithPlay(final Duration length) async {
    final Duration loaded = await _player.setAsset('assets/silence_30s.mp3');
    Duration targetEnd = length;
    if (loaded < targetEnd) {
      targetEnd = loaded;
      _log.warning('Could not pause for $targetEnd, clipping to $loaded.');
    }
    await _player.setClip(start: Duration.zero, end: targetEnd);
    await _player.pause();
    await _player.play();
  }
}
