import 'dart:collection';

import 'log.dart';
import 'results_db.dart';
import 'results_entities.dart';

final _log = Log.get('aggregated_drill_summary');

// Aggregates by start day. If byAction is true, returns a map from action to
// aggregated data. If byAction is false, the map contains a single entry with
// all actions.
Map<String, List<AggregatedActionReps>> aggregateAndSort(
    Iterable<AggregatedActionReps> input,
    {bool byAction = false}) {
  Map<String, AggregatedActionRepsBuilder> working = {};
  input.forEach((AggregatedActionReps item) {
    String key =
        byAction ? '${item.startDayStr}:${item.action}' : item.startDayStr;
    final builder = working.putIfAbsent(key, () {
      final builder = AggregatedActionRepsBuilder()
        ..startDayStr = item.startDayStr
        ..endDayStr = item.endDayStr;
      if (byAction) {
        builder.action = item.action;
      }
      return builder;
    });
    builder.reps += item.reps;
    if (item.accuracy != null) {
      builder.trackedReps += item.reps;
      builder.trackedGood += (item.reps * item.accuracy).round();
    }
  });
  final Map<String, List<AggregatedActionReps>> out = {};
  working.values.forEach((AggregatedActionRepsBuilder b) {
    final key = byAction ? b.action : 'all';
    final list = out.putIfAbsent(key, () => []);
    list.add(b.build());
  });
  out.values.forEach((aggList) {
    aggList.sort((a, b) => a.startDay.compareTo(b.startDay));
  });
  return out;
}
