import 'package:flutter/material.dart';

import 'app_rater.dart';
import 'drill_chooser_widget.dart';
import 'drill_data.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'static_drills.dart';

final _log = Log.get('drill_chooser_modal');

/// Let's the user choose a drill, or all drills.
/// This is intended to be shown with showDialog(), which returns the se
/// selected node as Future<DrillData>.
class DrillChooserModal extends StatelessWidget {
  static Future<DrillData?> startDialog(BuildContext context,
      {required StaticDrills staticDrills,
      required AppRater appRater,
      DrillData? selected,
      bool allowAll = false}) async {
    return Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => DrillChooserModal(
                  staticDrills: staticDrills,
                  appRater: appRater,
                  selected: selected,
                  allowAll: allowAll,
                )));
  }

  final StaticDrills staticDrills;
  final AppRater appRater;
  final DrillData? selected;
  final bool allowAll;

  DrillChooserModal(
      {required this.staticDrills,
      required this.appRater,
      this.selected,
      this.allowAll = false});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _onWillPop(context),
        child: Scaffold(
          appBar: MyAppBar(title: 'Choose Drill', appRater: appRater)
              .build(context),
          body: DrillChooserWidget(
              staticDrills: staticDrills,
              onDrillChosen: (DrillData? drill) =>
                  _onDrillChosen(context, drill),
              selected: selected,
              allowAll: allowAll),
        ));
  }

  void _onDrillChosen(BuildContext context, DrillData? drill) {
    _log.info('Drill chosen: ${drill?.fullName}');
    Navigator.pop(context, drill);
  }

  Future<bool> _onWillPop(BuildContext context) async {
    // Screen closed without selection, return the original value.
    Navigator.pop(context, selected);
    return true;
  }
}
