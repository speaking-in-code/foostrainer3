import 'package:flutter/material.dart';

import 'app_bar_chip.dart';
import 'drill_data.dart';
import 'log.dart';
import 'progress_chooser_sheet.dart';
import 'results_db.dart';
import 'static_drills.dart';

final _log = Log.get('time_window_chip');

class ProgressSelection {
  final DrillData drillData;
  final AggregationLevel aggLevel;

  ProgressSelection({this.drillData, @required this.aggLevel})
      : assert(aggLevel != null);

  ProgressSelection withAggLevel(AggregationLevel aggLevel) {
    return ProgressSelection(drillData: drillData, aggLevel: aggLevel);
  }

  ProgressSelection withDrillData(DrillData drillData) {
    return ProgressSelection(drillData: drillData, aggLevel: aggLevel);
  }
}

typedef OnProgressSelectionChange = void Function(ProgressSelection);

class ProgressSelectionChip extends StatefulWidget {
  final StaticDrills staticDrills;
  final ProgressSelection selected;
  final OnProgressSelectionChange onProgressChange;

  ProgressSelectionChip(
      {@required this.staticDrills,
      @required this.selected,
      this.onProgressChange})
      : assert(staticDrills != null),
        assert(selected != null);

  @override
  State<StatefulWidget> createState() => ProgressSelectionChipState(selected);
}

class ProgressSelectionChipState extends State<ProgressSelectionChip> {
  ProgressSelection selected;

  ProgressSelectionChipState(this.selected) : assert(selected != null);

  @override
  Widget build(BuildContext context) {
    final label = _buildLabel(context);
    return AppBarChip(label: label, onPressed: () => _onPressed(context));
  }

  Widget _buildLabel(BuildContext context) {
    if (selected.drillData == null) {
      return Text('All Drills');
    }
    // Consider switching to subtitle2/caption here.
    return Column(
      children: [
        Text(selected.drillData.type,
            style: Theme.of(context).textTheme.subtitle1),
        Text(selected.drillData.name,
            style: Theme.of(context).textTheme.bodyText2),
      ],
    );
  }

  void _onPressed(BuildContext context) async {
    ProgressSelection chosen = await showModalBottomSheet(
        context: context,
        builder: (context) => ProgressChooserSheet(
            staticDrills: widget.staticDrills, initialSelection: selected));
    widget.onProgressChange(chosen);
    setState(() {
      selected = chosen;
    });
  }
}
