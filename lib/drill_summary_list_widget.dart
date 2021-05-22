import 'package:flutter/material.dart';

import 'aggregated_drill_summary.dart';
import 'drill_data.dart';
import 'drill_details_widget.dart';
import 'drill_stats_screen.dart';
import 'practice_config_screen.dart';
import 'results_entities.dart';
import 'results_screen.dart';
import 'static_drills.dart';
import 'stats_grid_widget.dart';

/// Displays a list of drills in expandable cards. The expanded view shows
/// per-action statistics.
class DrillSummaryListWidget extends StatefulWidget {
  final StaticDrills staticDrills;
  final List<_PanelData> _panelData;

  DrillSummaryListWidget({this.staticDrills, List<DrillSummary> drills})
      : assert(staticDrills != null),
        _panelData = _toPanelData(drills);

  static List<_PanelData> _toPanelData(List<DrillSummary> drills) {
    return drills.map((drill) => _PanelData(drill)).toList();
    //final aggregated = AggregatedDrillSummary.aggregate(drills);
    //return aggregated.map((summary) => _PanelData(summary)).toList();
  }

  @override
  State<StatefulWidget> createState() => DrillSummaryListWidgetState();
}

class _PanelData {
  final DrillSummary drill;
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
    final drillData = widget.staticDrills.getDrill(panelData.drill.drill.drill);

    return ExpansionPanel(
        canTapOnHeader: true,
        headerBuilder: (BuildContext context, bool expanded) =>
            _buildHeader(context, panelData.drill, drillData),
        body: Column(children: [
          StatsGridWidget(summary: panelData.drill, drillData: drillData),
          _ActionButtons(drill: panelData.drill, drillData: drillData),
        ]),
        isExpanded: panelData.isExpanded);
  }

  Widget _buildHeader(
      BuildContext context, DrillSummary drill, DrillData drillData) {
    return ListTile(
        subtitle: _title(drill, drillData),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16));
  }

  Widget _title(DrillSummary drill, DrillData drillData) {
    final displayName = '${drillData.name}';
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
          flex: 3,
          child: Padding(
              padding: EdgeInsets.only(right: 5.0), child: Text(displayName))),
      // Expanded(flex: 1, child: Text('${drill.reps}')),
    ]);
  }
}

class _ActionButtons extends StatelessWidget {
  final DrillSummary drill;
  final DrillData drillData;

  _ActionButtons({this.drill, this.drillData});

  Widget build(BuildContext context) {
    return ButtonBar(children: [
      OutlinedButton(
          child: Text('Details'),
          onPressed: () =>
              ResultsScreen.push(context, drill.drill.id, drillData)),
      OutlinedButton(
          child: Text('History'),
          onPressed: () => DrillStatsScreen.navigate(context, drillData)),
      ElevatedButton(
          child: Text('Practice'),
          onPressed: () => PracticeConfigScreen.navigate(context, drillData)),
    ]);
  }
}
