import 'package:flutter/material.dart';
import 'package:ft3/practice_config_screen.dart';
import 'package:meta/meta.dart' show required;

import 'drill_data.dart';
import 'drill_stats_screen.dart';
import 'drill_types_screen.dart';
import 'stats_screen.dart';

enum MyNavBarLocation {
  PRACTICE,
  STATS,
}

class MyNavBar extends StatelessWidget {
  final MyNavBarLocation location;
  final DrillData drillData;

  MyNavBar({@required this.location, this.drillData});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: 'Practice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: (drillData != null ? 'Drill Stats' : 'Stats'),
          ),
        ],
        currentIndex: _getIndex(location),
        onTap: (int itemIndex) => _onTap(context, itemIndex));
  }

  int _getIndex(MyNavBarLocation location) {
    switch (location) {
      case MyNavBarLocation.PRACTICE:
        return 0;
      case MyNavBarLocation.STATS:
        return 1;
      default:
        throw Exception('Unknown location $location');
    }
  }

  void _onTap(BuildContext context, int itemIndex) {
    if (itemIndex == _getIndex(location)) {
      return;
    }
    switch (itemIndex) {
      case 0:
        if (drillData == null) {
          Navigator.pushNamed(context, DrillTypesScreen.routeName);
        } else {
          PracticeConfigScreen.navigate(context, drillData);
        }
        break;
      case 1:
        if (drillData == null) {
          Navigator.pushNamed(context, StatsScreen.routeName);
        } else {
          DrillStatsScreen.navigate(context, drillData);
        }
        break;
      default:
        throw Exception('Unknown tap location $itemIndex');
    }
  }
}
