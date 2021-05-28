import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:torch_compat/torch_compat.dart';

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

  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;

  DebugScreen({this.staticDrills, this.resultsDb});

  @override
  Widget build(BuildContext context) {
    Future<DebugInfoResponse> pauseInfo =
        AudioService.customAction(DebugInfo.action).then((value) {
      return DebugInfoResponse.fromJson(jsonDecode(value));
    });
    return Scaffold(
        appBar: MyAppBar(title: 'Debug').build(context),
        bottomNavigationBar: MyNavBar(location: MyNavBarLocation.practice),
        body: ListView(children: [
          Card(
              child: ListTile(
            title: Text('Clear Database'),
            onTap: () => _clearDatabase(context),
          )),
          Card(
              child: ListTile(
            title: Text('Init Database'),
            onTap: () => _initDatabase(context),
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
                onTap: () => null // TorchCompat.turnOn(),
                ),
          ),
          Card(
            child: ListTile(
                title: Text('Lamp Off'),
                onTap: () => null // TorchCompat.turnOff(),
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

  static const numDrills = 500;
  Future<void> _initDatabase(BuildContext context) async {
    final progress = ValueNotifier<int>(0);
    List<Future<void>> creations = [];
    for (int i = 0; i < numDrills; ++i) {
      creations.add(_initRandomPractice(progress));
    }
    bool dismissed = false;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Initializing Database'),
            content: _CreationProgress(progress: progress, target: numDrills),
            actions: [
              TextButton(
                  child: Text('Background'),
                  onPressed: () {
                    dismissed = true;
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
    await Future.wait(creations);
    if (!dismissed) {
      dismissed = true;
      Navigator.of(context).pop();
    }
    _showSnackBar(context, 'Database Initialized');
  }

  Future<void> _initRandomPractice(ValueNotifier<int> progress) async {
    const secondsPerYear = 365 * 24 * 3600;
    final when = DateTime.now()
        .subtract(Duration(seconds: _rand.nextInt(secondsPerYear)));
    final elapsedSeconds = _rand.nextInt(7200);
    bool tracking = _rand.nextBool();
    String drillType = _random(staticDrills.types);
    DrillData drillData = _random(staticDrills.getDrills(drillType));
    final drill = StoredDrill(
      startSeconds: when.millisecondsSinceEpoch ~/ 1000,
      drill: drillData.fullName,
      tracking: tracking,
      elapsedSeconds: elapsedSeconds,
    );
    final drillId = await resultsDb.drillsDao.insertDrill(drill);
    // Create the actions in batches.
    for (final action in drillData.actions) {
      final reps = _rand.nextInt(50);
      if (reps == 0) {
        continue;
      }
      int good = tracking ? _rand.nextInt(reps) : null;
      await resultsDb.actionsDao.insertAction(StoredAction(
          drillId: drillId, action: action.label, reps: reps, good: good));
    }
    ++progress.value;
  }

  static T _random<T>(List<T> list) {
    return list[_rand.nextInt(list.length)];
  }

  Future<void> _clearDatabase(BuildContext context) async {
    await resultsDb.deleteAll();
    _showSnackBar(context, 'Database Cleared');
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: 'OK',
            onPressed: () =>
                ScaffoldMessenger.of(context).removeCurrentSnackBar()));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class _CreationProgress extends StatefulWidget {
  final ValueNotifier<int> progress;
  final int target;

  _CreationProgress({this.progress, this.target});

  @override
  State<StatefulWidget> createState() => _CreationProgressState();
}

class _CreationProgressState extends State<_CreationProgress> {
  @override
  void initState() {
    super.initState();
    widget.progress.addListener(_onProgressChange);
  }

  void _onProgressChange() => setState(() {});

  @override
  void dispose() {
    widget.progress.removeListener(_onProgressChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
        value: widget.progress.value / widget.target);
  }
}
