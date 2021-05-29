import 'package:flutter/material.dart';

import 'drill_chooser_screen.dart';
import 'drill_data.dart';
import 'drill_description_tile.dart';
import 'log.dart';
import 'results_db.dart';
import 'static_drills.dart';
import 'progress_selection_chip.dart';

final _log = Log.get('progress_chooser_sheet');

class ProgressChooserSheet extends StatefulWidget {
  final StaticDrills staticDrills;
  final ProgressSelection initialSelection;

  ProgressChooserSheet(
      {@required this.staticDrills, @required this.initialSelection})
      : assert(staticDrills != null),
        assert(initialSelection != null);

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
        title: Text(_levelToString[option]),
        value: option,
        groupValue: selected.aggLevel,
        onChanged: (selected) => _onAggLevelSelected(context, selected),
      );
    }));
    return WillPopScope(
        onWillPop: _onWillPop, child: ListView(children: tiles));
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context, selected);
    return true;
  }

  void _onAggLevelSelected(BuildContext context, AggregationLevel aggLevel) {
    setState(() {
      selected = selected.copyWith(aggLevel: aggLevel);
    });
  }

  void _onDrillTap(BuildContext context) async {
    DrillData chosen = await DrillChooserScreen.startDialog(context,
        staticDrills: widget.staticDrills,
        selected: selected.drillData,
        allowAll: true);
    setState(() {
      selected = selected.copyWith(drillData: chosen);
    });
  }
}
