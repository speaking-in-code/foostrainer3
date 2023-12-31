import 'package:test/test.dart';
import 'package:ft3/duration_formatter.dart';

void main() {
  test('Knows zero elapsed time', () {
    expect(DurationFormatter.zero, '00:00:00');
  });

  test('Various seconds', () {
    expect(DurationFormatter.format(Duration(seconds: 0)), '00:00:00');
    expect(DurationFormatter.format(Duration(seconds: 1)), '00:00:01');
    expect(DurationFormatter.format(Duration(seconds: 2)), '00:00:02');
    expect(DurationFormatter.format(Duration(seconds: 59)), '00:00:59');
    expect(DurationFormatter.format(Duration(seconds: 60)), '00:01:00');
    expect(DurationFormatter.format(Duration(seconds: 79)), '00:01:19');
    expect(DurationFormatter.format(Duration(seconds: 3599)), '00:59:59');
    expect(DurationFormatter.format(Duration(seconds: 3600)), '01:00:00');
    expect(DurationFormatter.format(Duration(seconds: 7269)), '02:01:09');
  });

  test('Various minutes', () {
    expect(DurationFormatter.format(Duration(minutes: 0)), '00:00:00');
    expect(DurationFormatter.format(Duration(minutes: 1)), '00:01:00');
    expect(DurationFormatter.format(Duration(minutes: 2)), '00:02:00');
    expect(DurationFormatter.format(Duration(minutes: 59)), '00:59:00');
    expect(DurationFormatter.format(Duration(minutes: 60)), '01:00:00');
    expect(DurationFormatter.format(Duration(minutes: 79)), '01:19:00');
    expect(DurationFormatter.format(Duration(minutes: 3599)), '59:59:00');
  });

  test('Various milliseconds', () {
    expect(DurationFormatter.format(Duration(milliseconds: 0)), '00:00:00');
    expect(DurationFormatter.format(Duration(milliseconds: 1)), '00:00:00');
    expect(DurationFormatter.format(Duration(milliseconds: 499)), '00:00:00');
    expect(DurationFormatter.format(Duration(milliseconds: 500)), '00:00:00');
    expect(DurationFormatter.format(Duration(milliseconds: 999)), '00:00:00');
    expect(DurationFormatter.format(Duration(milliseconds: 1000)), '00:00:01');
  });

  test('Various days', () {
    expect(DurationFormatter.format(Duration(days: 1)), '24:00:00');
    expect(DurationFormatter.format(Duration(days: 2)), '48:00:00');
    expect(DurationFormatter.format(Duration(days: 100)), '2400:00:00');
  });

  test('Big random value', () {
    expect(
        DurationFormatter.format(
            Duration(days: 0, hours: 1, minutes: 23, seconds: 500)),
        '01:31:20');
  });
}
