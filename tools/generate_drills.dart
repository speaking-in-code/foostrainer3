/// Creates a json file with a list of drills.

import 'dart:convert';
import 'dart:io';

import '../lib/drill_data.dart';

DrillData _makeDrill(String type, String prefix, List<String> actions) {
  final nameRegexp = RegExp(r'[^A-Za-z0-9_/.]');
  var drill = DrillData(type: type);
  drill.name = actions.join('/');
  for (String action in actions) {
    String asset = 'assets/${prefix}_$action.mp3';
    asset = asset.toLowerCase().replaceAll(nameRegexp, '_');
    var actionData = ActionData(label: action, audioAsset: asset);
    if (!File(actionData.audioAsset).existsSync()) {
      throw ArgumentError('File ${actionData.audioAsset} not found.');
    }
    drill.actions.add(actionData);
  }
  return drill;
}

int main() {
  var drills = DrillListData();
  try {
    // Passes
    drills.drills.add(_makeDrill('Pass', 'pass', ['Lane']));
    drills.drills.add(_makeDrill('Pass', 'pass', ['Wall']));
    drills.drills.add(_makeDrill('Pass', 'pass', ['Lane', 'Wall']));
    drills.drills.add(_makeDrill('Pass', 'pass', ['Lane', 'Wall', 'Bounce']));
    drills.drills.add(_makeDrill(
        'Pass', 'pass', ['Lane', 'Wall', 'Bounce', 'Tic-Tac Wall']));

    // Rollovers
    drills.drills.add(_makeDrill('Rollover', 'shoot', ['Up']));
    drills.drills.add(_makeDrill('Rollover', 'shoot', ['Down']));
    drills.drills.add(_makeDrill('Rollover', 'shoot', ['Middle']));
    drills.drills.add(_makeDrill('Rollover', 'shoot', ['Up', 'Down']));
    drills.drills
        .add(_makeDrill('Rollover', 'shoot', ['Up', 'Down', 'Middle']));

    // Pull/Push shots
    drills.drills.add(_makeDrill('Pull/Push', 'shoot', ['Straight']));
    drills.drills.add(_makeDrill('Pull/Push', 'shoot', ['Middle']));
    drills.drills.add(_makeDrill('Pull/Push', 'shoot', ['Long']));
    drills.drills.add(_makeDrill('Pull/Push', 'shoot', ['Straight', 'Long']));
    drills.drills
        .add(_makeDrill('Pull/Push', 'shoot', ['Straight', 'Middle']));
    drills.drills.add(_makeDrill('Pull/Push', 'shoot', ['Middle', 'Long']));
    drills.drills.add(
        _makeDrill('Pull/Push', 'shoot', ['Straight', 'Middle', 'Long']));
  } on ArgumentError catch (e) {
    print('Error: ${e.message}');
    return 1;
  }

  File outputFile = new File('assets/drills.json');
  String text = JsonEncoder.withIndent('  ').convert(drills);
  outputFile.writeAsStringSync(text, flush: true);
  print('Created ${outputFile.path} with ${drills.drills.length} drills.');
  return 0;
}
