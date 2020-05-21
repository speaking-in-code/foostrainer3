/// Widget to display list of drills.
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'practice_background.dart';

class PracticeScreen extends StatelessWidget {
  static final log = Logger();
  static const routeName = '/practice';

  PracticeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: StreamBuilder<PracticeProgress>(
            stream: PracticeBackground.progressStream,
            builder: (context, snapshot) {
              log.i('Re-rendering practice screen, '
                  'connection: ${snapshot.connectionState}, '
                  'drill state: ${snapshot.data?.state}, '
                  'practice running: ${PracticeBackground.running}');
              if (!PracticeBackground.running) {
                // Drill was stopped via notification media controls.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pop(context);
                });
                return Scaffold();
              }
              var progress = snapshot?.data;
              if (progress == null) {
                // Stream still being initialized, use the passed in drill to
                // speed up rendering.
                progress = PracticeProgress.empty();
                progress.drill = ModalRoute.of(context).settings.arguments;
              }
              return Scaffold(
                  appBar: AppBar(title: Text('${progress.drill.name}')),
                  body: _PracticeScreenProgress(progress: progress));
            }));
  }

  // Stop the audio service on navigation away from this screen.
  Future<bool> _onWillPop() async {
    PracticeBackground.stopPractice();
    return true;
  }
}

class _PracticeScreenProgress extends StatelessWidget {
  final PracticeProgress progress;

  _PracticeScreenProgress({Key key, this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RaisedButton actionButton;
    if (progress.state == PracticeState.playing) {
      actionButton = RaisedButton(
          child: Icon(Icons.pause), onPressed: PracticeBackground.pause);
    } else {
      actionButton = RaisedButton(
          child: Icon(Icons.play_arrow), onPressed: PracticeBackground.play);
    }
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _data(context, '${progress.action}'),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _label(context, 'Reps'),
            _data(context, '${progress.shotCount}')
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _label(context, 'Time'),
            _data(context, '${progress.elapsed}')
          ],
        ),
      ]),
      actionButton
    ]);
  }

  Text _label(BuildContext context, String value) {
    return Text(value, style: Theme.of(context).textTheme.headline4);
  }

  Text _data(BuildContext context, String value) {
    return Text(value, style: Theme.of(context).textTheme.headline4);
  }
}
