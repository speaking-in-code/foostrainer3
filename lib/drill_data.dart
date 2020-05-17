// Data object describing a drill.
import 'package:meta/meta.dart';

// A single action, e.g. "Long", "Middle".
class ActionData {
  const ActionData({@required this.label, @required this.audioAsset});

  final String label;
  final String audioAsset;
}

// A set of actions with a name make up a drill.
class DrillData {
  const DrillData({@required this.name, @required this.actions});

  final String name;
  final List<ActionData> actions;
}