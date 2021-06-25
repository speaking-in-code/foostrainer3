import 'package:flutter/material.dart';

import 'drill_chooser_widget.dart';
import 'drill_data.dart';
import 'my_app_bar.dart';
import 'practice_config_screen.dart';
import 'static_drills.dart';

class DrillChooserScreen extends StatelessWidget {
  static const routeName = '/drillChooser';

  static void push(BuildContext context, DrillData selected) =>
      Navigator.pushNamed(context, routeName, arguments: selected);

  final StaticDrills staticDrills;

  DrillChooserScreen({@required this.staticDrills})
      : assert(staticDrills != null);

  @override
  Widget build(BuildContext context) {
    print('Rendering drill chooser screen');
    return Scaffold(
      appBar: MyAppBar(title: 'Choose Drill').build(context),
      body: DrillChooserWidget(
          staticDrills: staticDrills,
          onDrillChosen: (DrillData drill) => _onDrillChosen(context, drill),
          selected: ModalRoute.of(context).settings.arguments as DrillData,
          allowAll: false),
    );
  }

  void _onDrillChosen(BuildContext context, DrillData drill) {
    print('_onDrillChosen ${drill.fullName}');
    PracticeConfigScreen.navigate(context, drill);
  }
}
