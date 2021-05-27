import 'package:flutter/material.dart';

import 'drill_chooser_widget.dart';
import 'drill_data.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'static_drills.dart';

final _log = Log.get('drill_chooser_screen');

/// Let's the user choose a drill, or all drills.
/// This is intended to be shown with showDialog(), which returns the se
/// selected node as Future<DrillData>.
class DrillChooserScreen extends StatelessWidget {
  static Future<DrillData> startDialog(BuildContext context,
      {@required StaticDrills staticDrills,
      DrillData selected,
      bool allowAll = false}) async {
    DrillData chosen = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => DrillChooserScreen(
                  staticDrills: staticDrills,
                  selected: selected,
                  allowAll: allowAll,
                )));
    return chosen;
  }

  final StaticDrills staticDrills;
  final DrillData selected;
  final bool allowAll;

  DrillChooserScreen(
      {@required this.staticDrills, this.selected, this.allowAll = false})
      : assert(staticDrills != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Choose Drill').build(context),
      body: DrillChooserWidget(
          staticDrills: staticDrills,
          onDrillChosen: (DrillData drill) => _onDrillChosen(context, drill),
          selected: selected,
          allowAll: allowAll),
    );
  }

  void _onDrillChosen(BuildContext context, DrillData drill) {
    Navigator.pop(context, drill);
  }
}
