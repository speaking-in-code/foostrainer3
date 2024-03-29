import 'package:flutter/material.dart';

import 'drill_data.dart';
import 'home_screen.dart';
import 'monthly_drills_screen.dart';
import 'progress_screen.dart';

class MyNavBarLocation {
  final BottomNavigationBarItem item;
  final String route;

  const MyNavBarLocation._create({required this.item, required this.route});

  static const MyNavBarLocation practice = MyNavBarLocation._create(
      item: BottomNavigationBarItem(
        icon: Icon(Icons.play_arrow),
        label: 'Practice',
      ),
      route: HomeScreen.routeName);

  static const MyNavBarLocation monthly = MyNavBarLocation._create(
      item: BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today),
        label: 'History',
      ),
      route: MonthlyDrillsScreen.routeName);

  static const MyNavBarLocation progress = MyNavBarLocation._create(
      item: BottomNavigationBarItem(
        icon: Icon(Icons.show_chart),
        label: 'Progress',
      ),
      route: ProgressScreen.routeName);
}

class MyNavBar extends StatelessWidget {
  static MyNavBar forNormalNav(MyNavBarLocation location) {
    return MyNavBar._(location: location);
  }

  static MyNavBar forDrillNav(MyNavBarLocation location, DrillData? drillData) {
    return MyNavBar._(location: location, drillData: drillData);
  }

  static final _locations = [
    MyNavBarLocation.practice,
    MyNavBarLocation.monthly,
    MyNavBarLocation.progress,
  ];
  static final _indexToLocation = _locations.asMap();
  static final _locationToIndex =
      _indexToLocation.map((key, value) => MapEntry(value, key));
  static final _items = _locations.map((location) => location.item).toList();

  final MyNavBarLocation location;
  final int currentIndex;
  final DrillData? drillData;

  MyNavBar._({required this.location, this.drillData})
      : currentIndex = _locationToIndex[location]! {
    assert(currentIndex >= 0);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        items: _items,
        currentIndex: currentIndex,
        onTap: (int itemIndex) => _onTap(context, itemIndex));
  }

  void _onTap(BuildContext context, int itemIndex) {
    if (itemIndex != currentIndex) {
      final location = _locations[itemIndex];
      Navigator.pushReplacementNamed(context, location.route,
          arguments: drillData);
    }
  }
}
