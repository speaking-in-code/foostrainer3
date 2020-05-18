/// Widget to display list of drills.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'drill_data.dart';

class PracticeScreen extends StatelessWidget {
  static const routeName = '/practice';

  PracticeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DrillData drill = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(title: Text('${drill.name}')),
        body: _PracticeScreenProgress(drill: drill));
  }
}

class _PracticeScreenProgress extends StatefulWidget {
  _PracticeScreenProgress({Key key, @required this.drill}) : super(key: key);

  final DrillData drill;

  @override
  _PracticeScreenProgressState createState() => _PracticeScreenProgressState();
}

class _PracticeScreenProgressState extends State<_PracticeScreenProgress> {
  @override
  Widget build(BuildContext context) {
    String action = widget.drill.actions[0].label;
    int reps = 23;
    String elapsed = '00:10:23';
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _data(context, '$action'),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_label(context, 'Reps'), _data(context, '$reps')],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_label(context, 'Time'), _data(context, '$elapsed')],
        ),
      ]),
      RaisedButton(
          child: Icon(Icons.pause), onPressed: _pausePressed),
    ]);
  }

  Text _label(BuildContext context, String value) {
    return Text(value, style: Theme.of(context).textTheme.headline4);
  }

  Text _data(BuildContext context, String value) {
    return Text(value, style: Theme.of(context).textTheme.headline4);
  }

  void _pausePressed() {}

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
