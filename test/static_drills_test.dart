import 'package:flutter_test/flutter_test.dart';
import 'package:ft3/static_drills.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Loads', () async {
    StaticDrills drills = await StaticDrills.load()!;
    expect(drills.types, containsAll([
      'Pass',
      'Rollover',
      'Pull',
      'Push'
    ]));
  });

  test('All types have at least two drills', () async {
    StaticDrills drills = await StaticDrills.load()!;
    for (var type in drills.types!) {
      var drillsForType = drills.getDrills(type);
      expect(drillsForType.length, greaterThanOrEqualTo(2));
    }
  });
}