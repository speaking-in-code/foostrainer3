import 'dart:math';

import 'package:flutter/foundation.dart';

import 'drill_data.dart';

class RandomDelay {
  static final _rand = Random.secure();

  final Duration min;
  final Duration max;
  final Tempo tempo;

  RandomDelay({@required this.min, @required this.max, @required this.tempo});

  Duration get() {
    int start;
    int end;
    switch (tempo) {
      case Tempo.RANDOM:
        start = this.min.inMilliseconds;
        end = this.max.inMilliseconds;
        break;
      case Tempo.FAST:
        start = this.min.inMilliseconds;
        end = (this.max.inMilliseconds / 3).round();
        break;
      case Tempo.SLOW:
        start = (this.max.inMilliseconds * 2 / 3).round();
        end = this.max.inMilliseconds;
        break;
    }
    int window = end - start;
    return Duration(milliseconds: start + _rand.nextInt(window));
  }
}
