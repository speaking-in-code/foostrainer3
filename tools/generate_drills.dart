/// Creates a json file with a list of drills.

import 'dart:convert';
import 'dart:io';

import '../lib/drill_data.dart';

enum AudioPrefix {
  pass,
  shoot,
}

DrillData _makeDrill(
    String type, AudioPrefix prefixType, int maxSeconds, List<String> actions) {
  String prefix;
  switch (prefixType) {
    case AudioPrefix.pass:
      prefix = 'pass';
      break;
    case AudioPrefix.shoot:
      prefix = 'shoot';
      break;
    default:
      throw ArgumentError('Unknown prefix: $prefixType');
  }
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

DrillData _makePass(String type, AudioPrefix prefix, List<String> actions) {
  return _makeDrill(type, prefix, 10, actions);
}

DrillData _makeShot(String type, AudioPrefix prefix, List<String> actions) {
  return _makeDrill(type, prefix, 15, actions);
}

int main() {
  var drills = DrillListData();
  try {
    // Stick pass
    drills.drills.add(_makePass('Stick Pass', AudioPrefix.pass, ['Lane']));
    drills.drills.add(_makePass('Stick Pass', AudioPrefix.pass, ['Wall']));
    drills.drills
        .add(_makePass('Stick Pass', AudioPrefix.pass, ['Lane', 'Wall']));
    drills.drills.add(
        _makePass('Stick Pass', AudioPrefix.pass, ['Lane', 'Wall', 'Bounce']));
    drills.drills.add(_makePass('Stick Pass', AudioPrefix.pass,
        ['Lane', 'Wall', 'Bounce', 'Tic-Tac Wall']));

    // Brush pass
    drills.drills.add(_makePass('Brush Pass', AudioPrefix.pass, ['Lane']));
    drills.drills.add(_makePass('Brush Pass', AudioPrefix.pass, ['Wall']));
    drills.drills
        .add(_makePass('Brush Pass', AudioPrefix.pass, ['Lane', 'Wall']));

    // Rollovers
    drills.drills.add(_makeShot('Rollover', AudioPrefix.shoot, ['Up']));
    drills.drills.add(_makeShot('Rollover', AudioPrefix.shoot, ['Down']));
    drills.drills.add(_makeShot('Rollover', AudioPrefix.shoot, ['Middle']));
    drills.drills.add(_makeShot('Rollover', AudioPrefix.shoot, ['Up', 'Down']));
    drills.drills
        .add(_makeShot('Rollover', AudioPrefix.shoot, ['Up', 'Middle']));
    drills.drills
        .add(_makeShot('Rollover', AudioPrefix.shoot, ['Down', 'Middle']));
    drills.drills.add(
        _makeShot('Rollover', AudioPrefix.shoot, ['Up', 'Down', 'Middle']));

    // Pull/Push shots
    for (var type in ['Pull', 'Push']) {
      drills.drills.add(_makeShot(type, AudioPrefix.shoot, ['Straight']));
      drills.drills.add(_makeShot(type, AudioPrefix.shoot, ['Middle']));
      drills.drills.add(_makeShot(type, AudioPrefix.shoot, ['Long']));
      drills.drills
          .add(_makeShot(type, AudioPrefix.shoot, ['Straight', 'Long']));
      drills.drills
          .add(_makeShot(type, AudioPrefix.shoot, ['Straight', 'Middle']));
      drills.drills.add(_makeShot(type, AudioPrefix.shoot, ['Middle', 'Long']));
      drills.drills.add(
          _makeShot(type, AudioPrefix.shoot, ['Straight', 'Middle', 'Long']));
    }
  } on ArgumentError catch (e) {
    print('Error: ${e.message}');
    return 1;
  }

  File outputFile = new File('assets/drills.json');
  try {
    String text = JsonEncoder.withIndent('  ').convert(drills);
    outputFile.writeAsStringSync(text, flush: true);
    print('Created ${outputFile.path} with ${drills.drills.length} drills.');
  } catch (e) {
    print('Error: ${_errorToString(e)}');
    throw e;
  }
  // Verify the data.
  DrillListData.decode(outputFile.readAsStringSync());
  print('Verified output file.');
  return 0;
}

String _errorToString(Object error) {
  String msg = '$error';
  while (error.runtimeType == JsonUnsupportedObjectError) {
    error = (error as JsonUnsupportedObjectError).cause;
    msg += '\nCaused by $error';
  }
  return msg;
}
