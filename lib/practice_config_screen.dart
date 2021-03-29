/// Widget to display list of drills.
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
  static const tempoHeaderKey = Key(Keys.tempoHeaderKey);
  static const fastKey = Key(Keys.fastKey);
  static const slowKey = Key(Keys.slowKey);
  static const randomKey = Key(Keys.randomKey);
  static const playKey = Key(Keys.playKey);
  static const audioKey = Key(Keys.audioKey);
  static const audioAndFlashKey = Key(Keys.audioAndFlashKey);
  static const signalHeaderKey = Key(Keys.signalHeaderKey);
  static const trackingHeaderKey = Key(Keys.trackingHeaderKey);
  static const trackingAccuracyOnKey = Key(Keys.trackingAccuracyOnKey);
  static const trackingAccuracyOffKey = Key(Keys.trackingAccuracyOffKey);

  PracticeConfigScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PracticeConfigScreenState();
}

class _PracticeConfigScreenState extends State<PracticeConfigScreen> {
  // Unique ids for ExpansionPanelRadio widgets.
  static const kTempoId = 0;
  static const kDurationId = 1;
  static const kSignalId = 2;
  static const kTrackingId = 3;

  static const kDefaultMinutes = 10;
  DrillData _drill;
  double _practiceMinutes;

  @override
  Widget build(BuildContext context) {
    _drill = ModalRoute.of(context).settings.arguments;
    _drill.tempo ??= Tempo.RANDOM;
    _drill.signal ??= Signal.AUDIO;
    _drill.tracking ??= Tracking.ON;
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

  // Note: these panels don't obscure the FloatingActionButton, even on very
  // small screens in landscape orientation... but it's close. Might need to
  // add a spacer if the FAB and the other controls conflict in the future.
  Widget _expansionPanels() {
    List<ExpansionPanelRadio> children = [
      _tempoPicker(),
      _durationPicker(),
      _signalPicker(),
      _trackingPicker(),
    ];
    return SingleChildScrollView(
      child: Container(
        child: ExpansionPanelList.radio(
          children: children,
        ),
      ),
    );
  }

  ExpansionPanelRadio _tempoPicker() {
    return ExpansionPanelRadio(
        value: kTempoId,
        headerBuilder: _tempoHeader,
        canTapOnHeader: true,
        body: Column(children: [
          _makeTempo(PracticeConfigScreen.randomKey, Tempo.RANDOM),
          _makeTempo(PracticeConfigScreen.slowKey, Tempo.SLOW),
          _makeTempo(PracticeConfigScreen.fastKey, Tempo.FAST),
        ]));
  }

  Widget _tempoHeader(BuildContext context, bool isExpanded) {
    return ListTile(
        title: Text(
      'Tempo: ${_formatTempo(_drill.tempo)}',
      key: PracticeConfigScreen.tempoHeaderKey,
    ));
  }

  RadioListTile _makeTempo(Key key, Tempo tempo) {
    return RadioListTile<Tempo>(
      key: key,
      activeColor: Theme.of(context).buttonColor,
      title: Text(_formatTempo(tempo)),
      value: tempo,
      groupValue: _drill.tempo,
      onChanged: _onTempoChanged,
    );
  }

  void _onTempoChanged(Tempo tempo) {
    setState(() {
      _drill.tempo = tempo;
    });
  }

  String _formatTempo(Tempo tempo) {
    switch (tempo) {
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
        canTapOnHeader: true,
        headerBuilder: _durationHeader,
        body: _makeDurationSlider());
  }

  Widget _durationHeader(BuildContext context, bool isExpanded) {
    return ListTile(
        title: Text('Drill Time: ${_formatDuration()}',
            key: PracticeConfigScreen.drillTimeTextKey));
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
        canTapOnHeader: true,
        headerBuilder: _signalHeader,
        body: Column(children: [
          _makeSignal(PracticeConfigScreen.audioKey, Signal.AUDIO),
          _makeSignal(
              PracticeConfigScreen.audioAndFlashKey, Signal.AUDIO_AND_FLASH),
        ]));
  }

  Widget _signalHeader(BuildContext context, bool isExpanded) {
    return ListTile(
        title: Text('Signal: ${_formatSignal(_drill.signal)}',
            key: PracticeConfigScreen.signalHeaderKey));
  }

  String _formatSignal(Signal signal) {
    switch (signal) {
      case Signal.AUDIO_AND_FLASH:
        return 'Audio and Flash';
      case Signal.AUDIO:
        return 'Audio';
      default:
        return null;
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

  void _onSignalChanged(Signal signal) async {
    // iOS just lets us use the camera flash, no on-demand prompt for
    // permissions.
    if (signal == Signal.AUDIO_AND_FLASH && Platform.isAndroid) {
      PermissionStatus status = await Permission.camera.status;
      if (status != PermissionStatus.granted) {
        status = await Permission.camera.request();
      }
      if (status != PermissionStatus.granted) {
        signal = Signal.AUDIO;
      }
    }
    setState(() {
      _drill.signal = signal;
    });
  }

  ExpansionPanelRadio _trackingPicker() {
    return ExpansionPanelRadio(
        value: kTrackingId,
        canTapOnHeader: true,
        headerBuilder: _trackingHeader,
        body: Column(children: [
          _makeTracking(
              PracticeConfigScreen.trackingAccuracyOffKey, Tracking.OFF),
          _makeTracking(
              PracticeConfigScreen.trackingAccuracyOnKey, Tracking.ON),
        ]));
  }

  Widget _trackingHeader(BuildContext context, bool isExpanded) {
    return ListTile(
        title: Text('Accuracy Tracking: ${_formatTracking(_drill.tracking)}',
            key: PracticeConfigScreen.trackingHeaderKey));
  }

  String _formatTracking(Tracking tracking) {
    switch (tracking) {
      case Tracking.ON:
        return 'On';
      case Tracking.OFF:
        return 'Off';
      default:
        return null;
    }
  }

  RadioListTile _makeTracking(Key key, Tracking value) {
    return RadioListTile<Tracking>(
      key: key,
      activeColor: Theme.of(context).buttonColor,
      title: Text(_formatTracking(value)),
      value: value,
      groupValue: _drill.tracking,
      onChanged: _onTrackingChanged,
    );
  }

  void _onTrackingChanged(Tracking tracking) async {
    setState(() {
      _drill.tracking = tracking;
    });
  }

  Future<void> _startPractice() {
    // Workaround for https://github.com/flutter/flutter/issues/35521: don't
    // actually run the background process. Triggering native UI like music
    // players tends to trigger that bug.
    _log.info('Starting drill ${_drill.name}');
    _drill.practiceMinutes = _practiceMinutes.round();
    if (ScreenshotData.progress == null) {
      // Normal flow.
      PracticeBackground.startPractice(_drill);
    }
    Navigator.pushNamed(context, PracticeScreen.routeName, arguments: _drill);
    return Future.value();
  }

  String _formatDuration() {
    return '${_practiceMinutes.toStringAsFixed(0)} minutes';
  }
}
