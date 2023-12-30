// TODO: add tap targets to lead to per-drill and per-action stats over time.

import 'package:flutter/material.dart';
import 'stats_grid_widget.dart';

import 'drill_data.dart';
import 'results_entities.dart';

class DrillDetailsWidget extends StatelessWidget {
  final DrillSummary summary;
  final DrillData drillData;

  DrillDetailsWidget({required this.summary, required this.drillData});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: const EdgeInsets.all(8),
          child: Text(drillData.name,
              style: Theme.of(context).textTheme.titleLarge)),
      Center(child: StatsGridWidget(summary: summary, drillData: drillData)),
    ]));
  }
}
