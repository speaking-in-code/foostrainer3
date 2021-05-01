import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:torch_compat/torch_compat.dart';

import 'debug_info.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';

// Hidden screen for debug information. Accessed via long-press on the version
// information.
class DebugScreen extends StatelessWidget {
  final _log = Log.get('DebugScreen');
  static const routeName = '/debug';

  @override
  Widget build(BuildContext context) {
    Future<DebugInfoResponse> pauseInfo =
        AudioService.customAction(DebugInfo.action).then((value) {
      return DebugInfoResponse.fromJson(jsonDecode(value));
    });
    return Scaffold(
        appBar: MyAppBar(title: 'Debug').build(context),
        bottomNavigationBar: MyNavBar(MyNavBarLocation.PRACTICE),
        body: ListView(children: [
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
}
