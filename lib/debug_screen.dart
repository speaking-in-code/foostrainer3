import 'package:flutter/material.dart';

import 'my_app_bar.dart';

// Hidden screen for debug information. Accessed via long-press on the version
// information.
class DebugScreen extends StatelessWidget {
  static const routeName = '/debug';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(title: 'Debug').build(context),
        body: ListView(key: key, children: [
          _pauseDelays(),
        ]));
  }

  Widget _pauseDelays() {
    return Card(
        child: ListTile(
            title: Text('Pause Delay'),
            subtitle: Text('Mean: x ms. StdDev: y ms')));
  }
}
