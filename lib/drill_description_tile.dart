import 'package:flutter/material.dart';

import 'drill_data.dart';
import 'keys.dart';

class DrillDescriptionTile extends StatelessWidget {
  final DrillData? drillData;
  final Widget? trailing;
  final GestureTapCallback? onTap;

  DrillDescriptionTile({this.drillData, this.trailing, this.onTap})
      : super(key: Keys.drillSelectionKey);

  @override
  Widget build(BuildContext context) {
    Widget title;
    Widget? subtitle;
    if (drillData == null) {
      title = Text('All Drills');
    } else {
      title = Text(drillData!.type);
      subtitle = Text(drillData!.name);
    }
    return ListTile(
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
