import 'package:flutter/services.dart' show rootBundle;

import 'drill_data.dart';

/// Holds information about static drills in our app.
/// Usage: StaticDrills drills = await StaticDrills.load();
class StaticDrills {
  static Future<StaticDrills>? _allDrills;

  static Future<StaticDrills> load() async {
    if (_allDrills == null) {
      _allDrills = rootBundle
          .loadString('assets/drills.json')
          .then((value) => StaticDrills._create(value));
    }
    return _allDrills!;
  }

  Map<String, DrillData> _name2drills = {};
  Map<String, List<DrillData>> _type2drills = {};

  /// List of types of drills supported.
  late final List<String> types;

  StaticDrills._create(String json) {
    final drillListData = DrillListData.decode(json);
    for (DrillData drill in drillListData.drills) {
      var list = _type2drills.putIfAbsent(drill.type, () => []);
      list.add(drill);
      assert(!_name2drills.containsKey(drill.fullName),
          'Duplicate name ${drill.fullName}');
      _name2drills[drill.fullName] = drill;
    }
    types = List.of(_type2drills.keys);
  }

  /// Get a list of all drills of a specific type.
  List<DrillData> getDrills(String type) {
    return _type2drills[type] ?? [];
  }

  /// Get the drill with the specified name.
  DrillData? getDrill(String fullName) {
    return _name2drills[fullName];
  }
}
