import 'package:flutter/material.dart';

import 'drill_data.dart';
import 'play_button_widget.dart';
import 'static_drills.dart';

class NoDrillsWidget extends StatelessWidget {
  final StaticDrills staticDrills;
  final DrillData? drillData;

  const NoDrillsWidget({Key? key, required this.staticDrills, this.drillData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    final large = Theme.of(context).textTheme.headlineSmall;
    final medium = Theme.of(context).textTheme.titleLarge;
    final bigErrorText = Text('No Drills Found', style: large);
    if (drillData == null) {
      children.add(bigErrorText);
    } else {
      children.add(Column(children: [
        Text('${drillData!.type}', style: medium),
        SizedBox(height: 6),
        Text('${drillData!.name}', style: medium),
        SizedBox(height: 12),
        bigErrorText,
      ]));
    }
    children.add(
        PlayButtonWidget(staticDrills: staticDrills, drillData: drillData));
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: children);
  }
}
