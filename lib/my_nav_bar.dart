import 'package:flutter/material.dart';

import 'drill_types_screen.dart';
import 'stats_screen.dart';

enum MyNavBarLocation {
  PRACTICE,
  STATS,
}

class MyNavBar extends StatelessWidget {
  final MyNavBarLocation _current;

  MyNavBar(this._current);

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
            label: 'Stats',
          ),
        ],
        currentIndex: _getIndex(_current),
        onTap: (int location) => _onTap(context, location));
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

  void _onTap(BuildContext context, int index) {
    if (index == _getIndex(_current)) {
      return;
    }
    switch (index) {
      case 0:
        Navigator.pushNamed(context, DrillTypesScreen.routeName);
        break;
      case 1:
        Navigator.pushNamed(context, StatsScreen.routeName);
        break;
      default:
        throw Exception('Unknown tap location $index');
    }
  }
}
