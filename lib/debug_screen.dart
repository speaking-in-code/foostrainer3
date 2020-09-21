import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'debug_info.dart';
import 'my_app_bar.dart';

// Hidden screen for debug information. Accessed via long-press on the version
// information.
class DebugScreen extends StatelessWidget {
  static const routeName = '/debug';

  @override
  Widget build(BuildContext context) {
    Future<DebugInfoResponse> info = AudioService.customAction(DebugInfo.action)
        .then((value) => DebugInfoResponse.fromWire(value));
    return FutureBuilder(
        future: info,
        initialData: DebugInfoResponse(),
        builder: (context, AsyncSnapshot<DebugInfoResponse> snapshot) {
          return Scaffold(
              appBar: MyAppBar(title: 'Debug').build(context),
              body: ListView(children: [
                _pauseDelays(snapshot),
              ]));
        });
  }

  Widget _pauseDelays(final AsyncSnapshot<DebugInfoResponse> info) {
    final String subtitle =
        info.hasData ? _formatData(info.data) : info.error?.toString();
    return Card(
        child: ListTile(
      title: Text('Pause Delay'),
      subtitle: Text(subtitle),
    ));
  }

  String _formatData(DebugInfoResponse data) {
    String mean = data.meanDelayMillis.toStringAsFixed(1);
    String stdDev = data.stdDevDelayMillis.toStringAsFixed(1);
    return 'Mean: $mean ms. StdDev: $stdDev ms';
  }
}
