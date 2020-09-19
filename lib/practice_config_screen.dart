/// Widget to display list of drills.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'drill_data.dart';
import 'keys.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'practice_background.dart';
import 'practice_screen.dart';
import 'screenshot_data.dart';

final _log = Log.get('PracticeConfigScreen');

class PracticeConfigScreen extends StatefulWidget {
  static const routeName = '/practiceConfig';
  static const drillTimeSliderKey = Key(Keys.drillTimeSliderKey);
  static const drillTimeTextKey = Key(Keys.drillTimeTextKey);
  static const fastKey = Key(Keys.fastKey);
  static const slowKey = Key(Keys.slowKey);
  static const randomKey = Key(Keys.randomKey);
  static const playKey = Key(Keys.playKey);

  PracticeConfigScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PracticeConfigScreenState();
}

class _PracticeConfigScreenState extends State<PracticeConfigScreen> {
  static const kDefaultMinutes = 10;
  DrillData _drill;
  double _practiceMinutes;

  @override
  Widget build(BuildContext context) {
    _drill = ModalRoute.of(context).settings.arguments;
    _drill.tempo ??= Tempo.RANDOM;
    _practiceMinutes ??= (_drill.practiceMinutes ?? kDefaultMinutes).toDouble();
    return Scaffold(
      appBar: MyAppBar(title: _drill.name).build(context),
      body: ListView(
          padding:
              const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
          children: [
            _makeTempoPicker(),
            _makeDurationPicker(),
          ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).buttonColor,
        onPressed: _startPractice,
        child: Icon(Icons.play_arrow, key: PracticeConfigScreen.playKey),
      ),
    );
  }

  Future<void> _startPractice() {
    // Workaround for https://github.com/flutter/flutter/issues/35521, since
    // triggering native UI tends to trigger that bug.
    _log.info('Starting drill ${_drill.name}');
    _drill.practiceMinutes = _practiceMinutes.round();
    if (ScreenshotData.progress == null) {
      // Normal flow.
      PracticeBackground.startPractice(_drill);
    }
    Navigator.pushNamed(context, PracticeScreen.routeName, arguments: _drill);
    return Future.value();
  }

  Widget _makeTempoPicker() {
    return Card(
        child: Column(children: <Widget>[
      ListTile(title: const Text('Tempo')),
      _makeTempo(PracticeConfigScreen.randomKey, 'Random', Tempo.RANDOM),
      _makeTempo(PracticeConfigScreen.slowKey, 'Slow', Tempo.SLOW),
      _makeTempo(PracticeConfigScreen.fastKey, 'Fast', Tempo.FAST),
    ]));
  }

  RadioListTile _makeTempo(Key key, String label, Tempo value) {
    return RadioListTile<Tempo>(
      key: key,
      activeColor: Theme.of(context).buttonColor,
      title: Text(label),
      value: value,
      groupValue: _drill.tempo,
      onChanged: _onTempoChanged,
    );
  }

  void _onTempoChanged(Tempo tempo) {
    setState(() {
      _drill.tempo = tempo;
    });
  }

  Widget _makeDurationPicker() {
    return Card(
        child: Column(
      children: [
        ListTile(title: const Text('Drill Time')),
        _makeDurationSlider(),
      ],
    ));
  }

  Widget _makeDurationSlider() {
    return Row(children: [
      Expanded(
          child: Slider(
              activeColor: Theme.of(context).buttonColor,
              key: PracticeConfigScreen.drillTimeSliderKey,
              value: _practiceMinutes,
              min: 5,
              max: 60,
              divisions: 11,
              label: _formatDuration(),
              onChanged: (double duration) {
                setState(() {
                  _practiceMinutes = duration;
                });
              })),
      ConstrainedBox(
        constraints: BoxConstraints(minWidth: 100),
        child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(_formatDuration(),
                  key: PracticeConfigScreen.drillTimeTextKey),
            )),
      ),
    ]);
  }

  String _formatDuration() {
    return '${_practiceMinutes.toStringAsFixed(0)} minutes';
  }
}
