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
  static const audioKey = Key(Keys.audioKey);
  static const audioAndFlashKey = Key(Keys.audioAndFlashKey);

  PracticeConfigScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PracticeConfigScreenState();
}

class _PracticeConfigScreenState extends State<PracticeConfigScreen> {
  // Unique ids for ExpansionPanelRadio widgets.
  static const kTempoId = 0;
  static const kDurationId = 1;
  static const kSignalId = 2;

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
      body: _expansionPanels(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).buttonColor,
        onPressed: _startPractice,
        child: Icon(Icons.play_arrow, key: PracticeConfigScreen.playKey),
      ),
    );
  }

  Widget _expansionPanels() {
    return SingleChildScrollView(
        child: Container(
            child: ExpansionPanelList.radio(children: [
      _tempoPicker(),
      _durationPicker(),
      _signalPicker(),
    ])));
  }

  Widget _tempoHeader(BuildContext context, bool isExpanded) {
    return ListTile(title: Text('Tempo: ${_formatTempo()}'));
  }

  ExpansionPanelRadio _tempoPicker() {
    return ExpansionPanelRadio(
        value: kTempoId,
        headerBuilder: _tempoHeader,
        body: Column(children: [
          _makeTempo(PracticeConfigScreen.randomKey, 'Random', Tempo.RANDOM),
          _makeTempo(PracticeConfigScreen.slowKey, 'Slow', Tempo.SLOW),
          _makeTempo(PracticeConfigScreen.fastKey, 'Fast', Tempo.FAST),
        ]));
  }

  String _formatTempo() {
    switch (_drill.tempo) {
      case Tempo.SLOW:
        return 'Slow';
        break;
      case Tempo.FAST:
        return 'Fast';
        break;
      case Tempo.RANDOM:
        return 'Random';
        break;
    }
    return null;
  }

  ExpansionPanelRadio _durationPicker() {
    return ExpansionPanelRadio(
        value: kDurationId,
        headerBuilder: _durationHeader,
        body: _makeDurationSlider());
  }

  Widget _durationHeader(BuildContext context, bool isExpanded) {
    return ListTile(title: Text('Drill Time: ${_formatDuration()}'));
  }

  Widget _makeDurationSlider() {
    return Slider(
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
        });
  }

  ExpansionPanelRadio _signalPicker() {
    return ExpansionPanelRadio(
        value: kSignalId,
        headerBuilder: _signalHeader,
        body: Column(children: [
          _makeSignal(PracticeConfigScreen.audioKey, Signal.AUDIO),
          _makeSignal(
              PracticeConfigScreen.audioAndFlashKey, Signal.AUDIO_AND_FLASH),
        ]));
  }

  Widget _signalHeader(BuildContext context, bool isExpanded) {
    return ListTile(title: Text('Signal: ${_formatSignal(_drill.signal)}'));
  }

  String _formatSignal(Signal signal) {
    switch (signal) {
      case Signal.AUDIO_AND_FLASH:
        return 'Audio and Flash';
      case Signal.AUDIO:
      default:
        return 'Audio';
    }
  }

  RadioListTile _makeSignal(Key key, Signal value) {
    return RadioListTile<Signal>(
      key: key,
      activeColor: Theme.of(context).buttonColor,
      title: Text(_formatSignal(value)),
      value: value,
      groupValue: _drill.signal,
      onChanged: _onSignalChanged,
    );
  }

  void _onSignalChanged(Signal signal) {
    // TODO(brian): request permissions on Android M.
    setState(() {
      _drill.signal = signal;
    });
  }

  // TODO(brian): test out expansion panel with FAB on small screen device,
  // might need similar spacer.
  Widget _listView() {
    return ListView(
        padding:
            const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
        children: [
          //_makeTempoPicker(),
          //_makeDurationPicker(),
        ]);
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

  String _formatDuration() {
    return '${_practiceMinutes.toStringAsFixed(0)} minutes';
  }
}
