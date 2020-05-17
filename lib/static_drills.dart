/// All the drills that we can run

import 'drill_data.dart';

class StaticDrills {
  static const pass = const DrillData(
    name: 'Pass',
    actions: [
      const ActionData(label: 'Bounce', audioAsset: 'assets/pass_bounce.mp3'),
    ],
  );
}