import 'dart:async';

import 'package:flutter/material.dart';

import 'drill_chooser_modal.dart';
import 'drill_data.dart';
import 'drill_description_tile.dart';
import 'keys.dart';
import 'log.dart';
import 'results_db.dart';
import 'static_drills.dart';
import 'progress_selection_chip.dart';

final _log = Log.get('progress_chooser_sheet');

class ProgressChooserSheet extends StatefulWidget {
  // Workaround for screenshots, because closing modal dialogs via flutter
  // driver is hard: https://stackoverflow.com/questions/56602717/how-to-close-dialog-using-flutterdriver.
  static bool includeCloseButton = false;

  final StaticDrills staticDrills;
  final ProgressSelection initialSelection;

  ProgressChooserSheet(
      {required this.staticDrills, required this.initialSelection});

  @override
  State<StatefulWidget> createState() =>
      ProgressChooserSheetState(initialSelection);
}

class ProgressChooserSheetState extends State<ProgressChooserSheet> {
  static const _levelToString = {
    AggregationLevel.DAILY: 'Daily',
    AggregationLevel.WEEKLY: 'Weekly',
    AggregationLevel.MONTHLY: 'Monthly',
  };

  ProgressSelection selected;

  ProgressChooserSheetState(this.selected);

  @override
  Widget build(BuildContext context) {
    final List<Widget> tiles = [
      DrillDescriptionTile(
          drillData: selected.drillData,
          trailing: Icon(Icons.expand_more),
          onTap: () => _onDrillTap(context)),
      ListTile(title: Text('Time Window')),
    ];
    tiles.addAll(AggregationLevel.values.map((AggregationLevel option) {
      return RadioListTile<AggregationLevel>(
        title: Text(_levelToString[option]!),
        value: option,
        groupValue: selected.aggLevel,
        onChanged: (selected) => _onAggLevelSelected(context, selected),
      );
    }));
    if (ProgressChooserSheet.includeCloseButton) {
      tiles.add(ListTile(
          key: Key(Keys.progressChooserCloseKey),
          title: Text('Close'),
          onTap: () => Navigator.pop(context, selected)));
    }
    return WillPopScope(
        onWillPop: _onWillPop, child: ListView(children: tiles));
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context, selected);
    return true;
  }

  void _onAggLevelSelected(BuildContext context, AggregationLevel? aggLevel) {
    setState(() {
      selected = selected.withAggLevel(aggLevel!);
    });
  }

  void _onDrillTap(BuildContext context) async {
    DrillData chosen = await (DrillChooserModal.startDialog(context,
        staticDrills: widget.staticDrills,
        selected: selected.drillData,
        allowAll: true) as FutureOr<DrillData>);
    _log.info('Got drill ${chosen.fullName}');
    setState(() {
      selected = selected.withDrillData(chosen);
    });
  }
}
