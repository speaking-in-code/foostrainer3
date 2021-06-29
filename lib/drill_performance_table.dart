import 'package:flutter/material.dart';

import 'percent_formatter.dart';
import 'results_entities.dart';

class DrillPerformanceTable extends StatelessWidget {
  final DrillSummary summary;

  DrillPerformanceTable({required this.summary});

  Widget build(BuildContext context) {
    final List<DataColumn> columns = [
      DataColumn(label: Text('Action')),
      DataColumn(label: Text('Reps')),
      DataColumn(label: Text('Acc')),
    ];
    final List<DataRow> rows = [];
    if (summary.actions.length > 1) {
      rows.add(_buildTotal());
    }
    rows.addAll(summary.actions.values.map((action) => _buildRow(action)));
    return IgnorePointer(
        child: DataTable(columns: columns, rows: rows),
        ignoringSemantics: false);
  }

  DataRow _buildTotal() {
    int totalReps = 0;
    int? totalGood = summary.drill.tracking ? 0 : null;
    summary.actions.values.forEach((StoredAction action) {
      totalReps += action.reps;
      if (totalGood != null) {
        totalGood = totalGood! + action.good!;
      }
    });
    final total = StoredAction(
        drillId: 0, action: 'All', reps: totalReps, good: totalGood);
    return _buildRow(total);
  }

  DataRow _buildRow(StoredAction action) {
    final List<DataCell> cells = [];
    cells.add(DataCell(Text(action.action)));
    if (action.good != null) {
      cells.add(DataCell(Text('${action.good}/${action.reps}')));
    } else {
      cells.add(DataCell(Text('${action.reps}')));
    }
    final accuracy = PercentFormatter.format(action.accuracy);
    cells.add(DataCell(Text('$accuracy')));
    return DataRow(cells: cells);
  }
}
