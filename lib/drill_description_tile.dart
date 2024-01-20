import 'package:flutter/material.dart';

import 'drill_data.dart';
import 'keys.dart';

class DrillDescriptionTile extends StatelessWidget {
  final DrillData? drillData;
  final Widget? trailing;
  final GestureTapCallback? onTap;

  DrillDescriptionTile({this.drillData, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    Text title;
    Text? subtitle;
    String label;
    if (drillData == null) {
      title = Text('All Drills');
      label = 'Select All Drills';
    } else {
      title = Text(drillData!.type);
      subtitle = Text(drillData!.name);
      label = 'Select drill ${drillData!.type} - ${drillData!.name}';
    }
    return Semantics(
        label: label,
        child: ListTile(
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          onTap: onTap,
        ));
  }
}
