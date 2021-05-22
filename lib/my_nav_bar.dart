import 'package:flutter/material.dart';

import 'package:meta/meta.dart' show required;

import 'drill_stats_screen.dart';
import 'drill_types_screen.dart';
import 'monthly_drills_screen.dart';

class MyNavBarLocation {
  final BottomNavigationBarItem item;
  final String route;

  const MyNavBarLocation._create({@required this.item, @required this.route})
      : assert(item != null),
        assert(route != null);

  static const MyNavBarLocation practice = MyNavBarLocation._create(
      item: BottomNavigationBarItem(
        icon: Icon(Icons.directions_run),
        label: 'Practice',
      ),
      route: DrillTypesScreen.routeName);

  static const MyNavBarLocation monthly = MyNavBarLocation._create(
      item: BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today),
        label: 'History',
      ),
      route: MonthlyDrillsScreen.routeName);

  // TODO: this navigation won't work, make the drill stats screen show
  // some overall charts with drill down options.
  static const MyNavBarLocation stats = MyNavBarLocation._create(
      item: BottomNavigationBarItem(
        icon: Icon(Icons.show_chart),
        label: 'Stats',
      ),
      route: DrillStatsScreen.routeName);
}

class MyNavBar extends StatelessWidget {
  static final _locations = [
    MyNavBarLocation.practice,
    MyNavBarLocation.monthly,
    MyNavBarLocation.stats,
  ];
  static final _indexToLocation = _locations.asMap();
  static final _locationToIndex =
      _indexToLocation.map((key, value) => MapEntry(value, key));
  static final _items = _locations.map((location) => location.item).toList();

  final MyNavBarLocation location;
  final int currentIndex;

  MyNavBar({@required this.location})
      : currentIndex = _locationToIndex[location];

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Colors.black;
    return BottomNavigationBar(
        items: _items,
        currentIndex: currentIndex,
        onTap: (int itemIndex) => _onTap(context, itemIndex));
  }

  void _onTap(BuildContext context, int itemIndex) {
    if (itemIndex != currentIndex) {
      Navigator.pushReplacementNamed(context, _locations[itemIndex].route);
    }
  }
}
