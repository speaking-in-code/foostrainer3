// TODO: add tap targets to lead to per-drill and per-action stats over time.

import 'package:flutter/material.dart';

import 'aggregated_drill_summary.dart';
import 'percent_formatter.dart';

class DrillDetailsWidget extends StatelessWidget {
  final AggregatedDrillSummary drill;

  DrillDetailsWidget({@required this.drill}) : assert(drill != null);

  Widget build(BuildContext context) {
    final List<DataColumn> columns = [
      DataColumn(label: Text('Action')),
      DataColumn(label: Text('Reps')),
      DataColumn(label: Text('Accuracy')),
    ];
    final List<DataRow> rows = [];
    rows.add(_buildRow(AggregatedAction(
        action: 'Total',
        reps: drill.reps,
        trackedReps: drill.trackedReps,
        trackedGood: drill.trackedGood)));
    rows.addAll(drill.actions.values.map((action) => _buildRow(action)));
    final dataTextStyle = Theme.of(context).textTheme.caption;
    return DataTable(
      columns: columns,
      rows: rows,
      dataTextStyle: dataTextStyle,
    );
  }

  DataRow _buildRow(AggregatedAction action) {
    final List<DataCell> cells = [];
    cells.add(DataCell(Text(action.action)));
    int estimatedGood = action.estimatedGood;
    if (estimatedGood != null) {
      cells.add(DataCell(Text('$estimatedGood/${action.reps}')));
    } else {
      cells.add(DataCell(Text('${action.reps}')));
    }
    final accuracy = PercentFormatter.formatAccuracy(
        trackedReps: action.trackedReps, trackedGood: action.trackedGood);
    cells.add(DataCell(Text('$accuracy')));
    return DataRow(cells: cells);
  }
}
