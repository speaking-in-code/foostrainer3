/// Widget to display list of drills.

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

import 'drill_data.dart';

class Drill extends StatelessWidget {
  final DrillData drillData;

  Drill({Key key, @required this.drillData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('${drillData.name}')),
        body: _DrillProgress());
  }
}

class _DrillProgress extends StatefulWidget {
  _DrillProgress({Key key}) : super(key: key);

  @override
  _DrillProgressState createState() => _DrillProgressState();
}

class _DrillProgressState extends State<_DrillProgress> {
  final String _action = 'Lane';
  final int _reps = 10;
  final String _elapsed = '00:10:23';

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _data(context, '$_action'),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_label(context, 'Reps'), _data(context, '$_reps')],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_label(context, 'Time'), _data(context, '$_elapsed')],
        ),
      ]),
      RaisedButton(
          child: Icon(Icons.stop), onPressed: _stopPressed),
    ]);
  }

  Text _label(BuildContext context, String value) {
    return Text(value, style: Theme.of(context).textTheme.headline4);
  }

  Text _data(BuildContext context, String value) {
    return Text(value, style: Theme.of(context).textTheme.headline4);
  }

  void _stopPressed() {}

  void _playPressed() {}
}
/*
class Drill extends StatefulWidget {
  final DrillData drillData;

  Drill({Key key, @required this.drillData}) : super(key: key) {
    Logger().i('Drill widget: ${drillData.name}');
  }

  @override
  _DrillState createState() => _DrillState();
}

class _DrillState extends State<Drill> {
  String _action;
  int _reps;
  String _elapsed;

  _DrillState();

  _stopPressed() {}
  _playPressed() {}

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('${widget.drillData.name}',
          style: Theme.of(context).textTheme.headline4),
      Text('$_action'),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Reps'), Text('$_reps')],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Time'), Text('$_elapsed')],
        ),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        RaisedButton(
            child: Icon(Icons.stop), onPressed: _stopPressed),
        RaisedButton(
            child: Icon(Icons.play_arrow), onPressed: _playPressed),
      ]),
    ]);
  }
}
      */
