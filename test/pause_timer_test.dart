import 'package:flutter_test/flutter_test.dart';
import 'package:ft3/pause_timer.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final player = AudioPlayer();

  test('Handles No Values', () {
    final timer = PauseTimer(player);
    final metrics = timer.calculateDelayMetrics();
    expect(metrics.meanDelayMillis, equals(0));
    expect(metrics.stdDevDelayMillis, equals(0));
  });

  test('Handles one value', () {
    final timer = PauseTimer(player);
    timer.updateMetrics(Duration(milliseconds: 20));
    final metrics = timer.calculateDelayMetrics();
    expect(metrics.meanDelayMillis, moreOrLessEquals(20));
    expect(metrics.stdDevDelayMillis, moreOrLessEquals(0));
  });

  test('Handles many values', () {
    final timer = PauseTimer(player);
    for (int i = 0; i < 5; ++i) {
      timer.updateMetrics(Duration(milliseconds: 20));
    }
    final metrics = timer.calculateDelayMetrics();
    expect(metrics.meanDelayMillis, moreOrLessEquals(20));
    expect(metrics.stdDevDelayMillis, moreOrLessEquals(0));
  });

  test('Does stats correctly', () {
    final timer = PauseTimer(player);
    timer.updateMetrics(Duration(milliseconds: 0));
    timer.updateMetrics(Duration(milliseconds: 0));
    timer.updateMetrics(Duration(milliseconds: 10));
    timer.updateMetrics(Duration(milliseconds: 30));
    final metrics = timer.calculateDelayMetrics();
    expect(metrics.meanDelayMillis, moreOrLessEquals(10));
    expect(metrics.stdDevDelayMillis, moreOrLessEquals(12.247, epsilon: 0.001));
  });

  test('Discards old data', () {
    final timer = PauseTimer(player);
    for (int i = 0; i < 100; ++i) {
      timer.updateMetrics(Duration(milliseconds: 0));
    }
    var metrics = timer.calculateDelayMetrics();
    expect(metrics.meanDelayMillis, moreOrLessEquals(0));
    expect(metrics.stdDevDelayMillis, moreOrLessEquals(0));
    for (int i = 0; i < 100; ++i) {
      timer.updateMetrics(Duration(milliseconds: 10));
    }
    metrics = timer.calculateDelayMetrics();
    expect(metrics.meanDelayMillis, moreOrLessEquals(10));
    expect(metrics.stdDevDelayMillis, moreOrLessEquals(0));
  });
}
