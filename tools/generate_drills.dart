/// Creates a json file with a list of drills.

import 'dart:convert';
import 'dart:io';

import '../lib/drill_data.dart';

DrillData _makeDrill(
    String type, String prefix, int maxSeconds, List<String> actions) {
  final nameRegexp = RegExp(r'[^A-Za-z0-9_/.]');
  var drill = DrillData(type: type, possessionSeconds: maxSeconds);
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

DrillData _makePass(String type, String prefix, List<String> actions) {
  return _makeDrill(type, prefix, 10, actions);
}

DrillData _makeShot(String type, String prefix, List<String> actions) {
  return _makeDrill(type, prefix, 15, actions);
}

int main() {
  var drills = DrillListData();
  try {
    // Passes
    drills.drills.add(_makePass('Pass', 'pass', ['Lane']));
    drills.drills.add(_makePass('Pass', 'pass', ['Wall']));
    drills.drills.add(_makePass('Pass', 'pass', ['Lane', 'Wall']));
    drills.drills.add(_makePass('Pass', 'pass', ['Lane', 'Wall', 'Bounce']));
    drills.drills.add(
        _makePass('Pass', 'pass', ['Lane', 'Wall', 'Bounce', 'Tic-Tac Wall']));

    // Rollovers
    drills.drills.add(_makeShot('Rollover', 'shoot', ['Up']));
    drills.drills.add(_makeShot('Rollover', 'shoot', ['Down']));
    drills.drills.add(_makeShot('Rollover', 'shoot', ['Middle']));
    drills.drills.add(_makeShot('Rollover', 'shoot', ['Up', 'Down']));
    drills.drills.add(_makeShot('Rollover', 'shoot', ['Up', 'Middle']));
    drills.drills.add(_makeShot('Rollover', 'shoot', ['Down', 'Middle']));
    drills.drills.add(_makeShot('Rollover', 'shoot', ['Up', 'Down', 'Middle']));

    // Pull/Push shots
    for (var type in ['Pull', 'Push']) {
      drills.drills.add(_makeShot(type, 'shoot', ['Straight']));
      drills.drills.add(_makeShot(type, 'shoot', ['Middle']));
      drills.drills.add(_makeShot(type, 'shoot', ['Long']));
      drills.drills.add(_makeShot(type, 'shoot', ['Straight', 'Long']));
      drills.drills.add(_makeShot(type, 'shoot', ['Straight', 'Middle']));
      drills.drills.add(_makeShot(type, 'shoot', ['Middle', 'Long']));
      drills.drills
          .add(_makeShot(type, 'shoot', ['Straight', 'Middle', 'Long']));
    }
  } on ArgumentError catch (e) {
    print('Error: ${e.message}');
    return 1;
  }

  File outputFile = new File('assets/drills.json');
  String text = JsonEncoder.withIndent('  ').convert(drills);
  outputFile.writeAsStringSync(text, flush: true);
  print('Created ${outputFile.path} with ${drills.drills.length} drills.');

  // Verify the data.
  DrillListData.fromJson(jsonDecode(outputFile.readAsStringSync()));
  print('Verified output file.');
  return 0;
}
