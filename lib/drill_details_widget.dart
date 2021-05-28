// TODO: add tap targets to lead to per-drill and per-action stats over time.

import 'package:flutter/material.dart';
import 'package:ft3/stats_grid_widget.dart';

import 'aggregated_drill_summary.dart';
import 'drill_data.dart';
import 'duration_formatter.dart';
import 'percent_formatter.dart';
import 'results_entities.dart';

class DrillDetailsWidget extends StatelessWidget {
  final DrillSummary summary;
  final DrillData drillData;

  DrillDetailsWidget({this.summary, this.drillData});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: const EdgeInsets.all(8),
          child: Text(drillData.name,
              style: Theme.of(context).textTheme.headline6)),
      Center(child: StatsGridWidget(summary: summary, drillData: drillData)),
    ]));
  }
}
