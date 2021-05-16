import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:torch_compat/torch_compat.dart';

import 'debug_info.dart';
import 'drill_data.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'static_drills.dart';

// Hidden screen for debug information. Accessed via long-press on the version
// information.
class DebugScreen extends StatelessWidget {
  static const routeName = '/debug';
  static final _rand = Random.secure();
  static final _log = Log.get('DebugScreen');

  final ResultsDatabase resultsDb;
  final StaticDrills drills;

  DebugScreen(this.resultsDb, this.drills);

  @override
  Widget build(BuildContext context) {
    Future<DebugInfoResponse> pauseInfo =
        AudioService.customAction(DebugInfo.action).then((value) {
      return DebugInfoResponse.fromJson(jsonDecode(value));
    });
    return Scaffold(
        appBar: MyAppBar(title: 'Debug').build(context),
        bottomNavigationBar: MyNavBar(location: MyNavBarLocation.PRACTICE),
        body: ListView(children: [
          Card(
              child: ListTile(
            title: Text('Clear Database'),
            onTap: () => resultsDb.deleteAll(),
          )),
          Card(
              child: ListTile(
            title: Text('Init Database'),
            onTap: () => _initDatabase(),
          )),
          FutureBuilder(
              future: pauseInfo,
              initialData: DebugInfoResponse(),
              builder: _pauseDelays),
          FutureBuilder(
            future: Permission.camera.status,
            builder: _permissionStatus,
          ),
          Card(
            child: ListTile(
              title: Text('Lamp On'),
              onTap: () => TorchCompat.turnOn(),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Lamp Off'),
              onTap: () => TorchCompat.turnOff(),
            ),
          ),
        ]));
  }

  Widget _pauseDelays(
      BuildContext context, final AsyncSnapshot<DebugInfoResponse> info) {
    final String subtitle =
        info.hasData ? _formatData(info.data) : info.error?.toString();
    return Card(
        child: ListTile(
      title: Text('Pause Delay'),
      subtitle: Text(subtitle),
    ));
  }

  String _formatData(DebugInfoResponse data) {
    String mean = data.meanDelayMillis?.toStringAsFixed(1);
    String stdDev = data.stdDevDelayMillis?.toStringAsFixed(1);
    return 'Mean: $mean ms. StdDev: $stdDev ms';
  }

  Widget _permissionStatus(
      BuildContext context, final AsyncSnapshot<PermissionStatus> snapshot) {
    String label;
    if (snapshot.hasData) {
      label = '${snapshot.data}';
    } else if (snapshot.hasError) {
      label = '${snapshot.error}';
    } else {
      label = 'unknown';
    }
    return Card(
      child: ListTile(
        title: Text('Flash Permission'),
        subtitle: Text(label),
      ),
    );
  }

  Future<void> _initDatabase() async {
    List<Future<void>> creations = [];
    for (int i = 0; i < 100; ++i) {
      creations.add(_initRandomPractice());
    }
    return Future.wait(creations);
  }

  Future<void> _initRandomPractice() async {
    const secondsPerYear = 365 * 24 * 3600;
    final when = DateTime.now()
        .subtract(Duration(seconds: _rand.nextInt(secondsPerYear)));
    final elapsedSeconds = _rand.nextInt(7200);
    bool tracking = _rand.nextBool();
    String drillType = _random(drills.types);
    DrillData drillData = _random(drills.getDrills(drillType));
    final drill = StoredDrill(
      startSeconds: when.millisecondsSinceEpoch ~/ 1000,
      drill: drillData.fullName,
      tracking: tracking,
      elapsedSeconds: elapsedSeconds,
    );
    final id = await resultsDb.drillsDao.insertDrill(drill);
    int reps = _rand.nextInt(150);
    for (int i = 0; i < reps; ++i) {
      final action = _random(drillData.actions).label;
      bool good = tracking ? _rand.nextBool() : null;
      await resultsDb.actionsDao.incrementAction(id, action, good);
    }
  }

  static T _random<T>(List<T> list) {
    return list[_rand.nextInt(list.length)];
  }
}
