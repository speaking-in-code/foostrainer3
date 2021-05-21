import 'dart:collection';

import 'log.dart';
import 'results_entities.dart';

final _log = Log.get('aggregated_drill_summary');

class AggregatedAction {
  final String action;
  final int reps;
  final int trackedReps; // nullable
  final int trackedGood; // nullable

  int get estimatedGood => _estimatedGood(
      reps: reps, trackedReps: trackedReps, trackedGood: trackedGood);

  double get accuracy =>
      trackedGood != null ? estimatedGood / trackedReps : null;

  AggregatedAction(
      {this.action, this.reps, this.trackedReps, this.trackedGood});
}

int _estimatedGood({int reps, int trackedReps, int trackedGood}) {
  if (trackedReps == null) {
    return null;
  }
  if (trackedReps == 0) {
    return 0;
  }
  return ((trackedGood / trackedReps) * reps).round();
}

class AggregatedActionBuilder {
  final String action;
  int reps = 0;
  int trackedReps; // nullable
  int trackedGood; // nullable

  AggregatedActionBuilder(this.action);

  AggregatedAction build() => AggregatedAction(
      action: action,
      reps: reps,
      trackedReps: trackedReps,
      trackedGood: trackedGood);
}

class AggregatedDrillSummary {
  final String drill;
  final int reps;
  final int trackedReps; // nullable
  final int trackedGood; // nullable
  final Map<String, AggregatedAction> actions;

  AggregatedDrillSummary(
      {this.drill,
      this.reps,
      this.trackedReps,
      this.trackedGood,
      this.actions});

  factory AggregatedDrillSummary.fromSummary(DrillSummary drill) {
    final builder = _AggregatedDrillSummaryBuilder(drill.drill.drill);
    builder.merge(drill);
    return builder.build();
  }

  int get estimatedGood => _estimatedGood(
      reps: reps, trackedReps: trackedReps, trackedGood: trackedGood);

  static List<AggregatedDrillSummary> aggregate(Iterable<DrillSummary> drills) {
    Map<String, _AggregatedDrillSummaryBuilder> agg = SplayTreeMap();
    drills.forEach((DrillSummary drill) {
      final builder = agg.putIfAbsent(drill.drill.drill,
          () => _AggregatedDrillSummaryBuilder(drill.drill.drill));
      builder.merge(drill);
    });
    return agg.values.map((builder) => builder.build()).toList();
  }
}

class _AggregatedDrillSummaryBuilder {
  final String drillName;
  int reps = 0;
  int trackedGood; // nullable
  int trackedReps; // nullable
  Map<String, AggregatedActionBuilder> actions = {};

  _AggregatedDrillSummaryBuilder(this.drillName);

  void merge(DrillSummary drill) {
    // _log.info('Merging ${drill.encode()}');
    reps += drill.reps;
    if (drill.good != null) {
      trackedReps ??= 0;
      trackedReps += drill.reps;
      trackedGood ??= 0;
      trackedGood += drill.good;
    }
    drill.actions.values.forEach((StoredAction action) {
      final agg = actions.putIfAbsent(
          action.action, () => AggregatedActionBuilder(action.action));
      agg.reps += action.reps;
      if (action.good != null) {
        agg.trackedReps ??= 0;
        agg.trackedReps += action.reps;
        agg.trackedGood ??= 0;
        agg.trackedGood += action.good;
      }
    });
  }

  AggregatedDrillSummary build() {
    SplayTreeMap<String, AggregatedAction> outActions = SplayTreeMap();
    actions.forEach((key, value) {
      outActions[key] = value.build();
    });
    return AggregatedDrillSummary(
        drill: drillName,
        reps: reps,
        trackedGood: trackedGood,
        trackedReps: trackedReps,
        actions: outActions);
  }
}
