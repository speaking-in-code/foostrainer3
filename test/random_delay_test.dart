import 'package:ft3/drill_data.dart';
import 'package:ft3/random_delay.dart';
import 'package:test/test.dart';

void main() {
  const Duration minPass = Duration(seconds: 3);
  const Duration maxPass = Duration(seconds: 10);
  const Duration minShot = Duration(seconds: 3);
  const Duration maxShot = Duration(seconds: 15);

  void verifyRange(RandomDelay random, Duration min, Duration max) {
    for (int i = 0; i < 100; ++i) {
      Duration delay = random.get();
      expect(delay.inMilliseconds, greaterThanOrEqualTo(min.inMilliseconds));
      expect(delay.inMilliseconds, lessThanOrEqualTo(max.inMilliseconds));
    }
  }

  test('Pass, random', () {
    var random = RandomDelay(min: minPass, max: maxPass, tempo: Tempo.RANDOM);
    verifyRange(random, minPass, maxPass);
  });

  test('Pass, slow', () {
    var random = RandomDelay(min: minPass, max: maxPass, tempo: Tempo.SLOW);
    verifyRange(random, Duration(milliseconds: 6666), maxPass);
  });

  test('Pass, fast', () {
    var random = RandomDelay(min: minPass, max: maxPass, tempo: Tempo.FAST);
    verifyRange(random, Duration(seconds: 3), Duration(milliseconds: 3333));
  });

  test('Shot, random', () {
    var random = RandomDelay(min: minShot, max: maxShot, tempo: Tempo.RANDOM);
    verifyRange(random, minShot, maxShot);
  });

  test('Shot, slow', () {
    var random = RandomDelay(min: minShot, max: maxShot, tempo: Tempo.SLOW);
    verifyRange(random, Duration(seconds: 10), maxShot);
  });

  test('Shot, fast', () {
    var random = RandomDelay(min: minShot, max: maxShot, tempo: Tempo.FAST);
    verifyRange(random, Duration(seconds: 3), Duration(seconds: 5));
  });
}
