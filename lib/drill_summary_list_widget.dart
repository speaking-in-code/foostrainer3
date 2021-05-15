import 'package:flutter/material.dart';

import 'aggregated_drill_summary.dart';
import 'drill_data.dart';
import 'practice_config_screen.dart';
import 'results_entities.dart';
import 'percent_formatter.dart';
import 'static_drills.dart';
import 'stats_screen.dart';

/// Displays a list of drills in expandable cards. The expanded view shows
/// per-action statistics.
class DrillSummaryListWidget extends StatefulWidget {
  final StaticDrills staticDrills;
  final List<_PanelData> _panelData;

  DrillSummaryListWidget({this.staticDrills, List<DrillSummary> drills})
      : assert(staticDrills != null),
        _panelData = _toPanelData(drills);

  static List<_PanelData> _toPanelData(List<DrillSummary> drills) {
    final aggregated = AggregatedDrillSummary.aggregate(drills);
    return aggregated.map((summary) => _PanelData(summary)).toList();
  }

  @override
  State<StatefulWidget> createState() => DrillSummaryListWidgetState();
}

class _PanelData {
  final AggregatedDrillSummary drill;
  bool isExpanded = false;

  _PanelData(this.drill);
}

class DrillSummaryListWidgetState extends State<DrillSummaryListWidget> {
  @override
  Widget build(BuildContext context) {
    List<ExpansionPanel> panels = widget._panelData.map(_buildPanel).toList();
    return ExpansionPanelList(
        children: panels,
        expansionCallback: _expansionCallback,
        expandedHeaderPadding: EdgeInsets.zero);
  }

  void _expansionCallback(int panelIndex, bool currentExpanded) {
    setState(() {
      widget._panelData[panelIndex].isExpanded = !currentExpanded;
    });
  }

  ExpansionPanel _buildPanel(_PanelData panelData) {
    return ExpansionPanel(
        canTapOnHeader: true,
        headerBuilder: (BuildContext context, bool expanded) =>
            _buildHeader(context, panelData.drill),
        body: Column(children: [
          _DrillDetails(drill: panelData.drill),
          _ActionButtons(
              staticDrills: widget.staticDrills, drill: panelData.drill),
        ]),
        isExpanded: panelData.isExpanded);
  }

  Widget _buildHeader(BuildContext context, AggregatedDrillSummary drill) {
    return ListTile(
        subtitle: _title(drill),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16));
  }

  Widget _title(AggregatedDrillSummary drill) {
    final drillData = widget.staticDrills.getDrill(drill.drill);
    final displayName = '${drillData.type}: ${drillData.name}';
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
          flex: 3,
          child: Padding(
              padding: EdgeInsets.only(right: 5.0), child: Text(displayName))),
      Expanded(flex: 1, child: Text('${drill.reps}')),
    ]);
  }
}

// TODO: add tap targets to lead to per-drill and per-action stats over time.
class _DrillDetails extends StatelessWidget {
  final AggregatedDrillSummary drill;

  _DrillDetails({this.drill});

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
    return DataTable(columns: columns, rows: rows);
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

class _ActionButtons extends StatelessWidget {
  final StaticDrills staticDrills;
  final AggregatedDrillSummary drill;

  _ActionButtons({this.staticDrills, this.drill});

  Widget build(BuildContext context) {
    final DrillData drillData = staticDrills.getDrill(drill.drill);
    return ButtonBar(children: [
      OutlinedButton(
          child: Text('History'),
          onPressed: () => StatsScreen.navigate(context, drillData)),
      ElevatedButton(
          child: Text('Practice'),
          onPressed: () => PracticeConfigScreen.navigate(context, drillData)),
    ]);
  }
}
