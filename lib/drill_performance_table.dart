import 'package:flutter/material.dart';

import 'percent_formatter.dart';
import 'results_entities.dart';

class DrillPerformanceTable extends StatelessWidget {
  final DrillSummary summary;

  DrillPerformanceTable({this.summary});

  Widget build(BuildContext context) {
    final List<DataColumn> columns = [
      DataColumn(label: Text('Action')),
      DataColumn(label: Text('Reps')),
      DataColumn(label: Text('Acc')),
    ];
    final List<DataRow> rows = [];
    rows.addAll(summary.actions.values.map((action) => _buildRow(action)));
    return IgnorePointer(
        child: DataTable(columns: columns, rows: rows),
        ignoringSemantics: false);
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
