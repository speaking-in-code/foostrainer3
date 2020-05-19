import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'drill_data.dart';
import 'drill_task.dart';
import 'practice_screen.dart';

// Displays a list of drills.
class DrillListScreen extends StatelessWidget {
  static final log = Logger();
  static const routeName = '/drillList';

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute settings and cast
    // them as ScreenArguments.
    final List<DrillData> drills = ModalRoute.of(context).settings.arguments;
    var children = List<Widget>();
    String type = drills[0]?.type ?? '';
    for (DrillData drill in drills) {
      children.add(Card(
          child: ListTile(
              title: Text(drill.name),
              onTap: () => _startDrill(context, drill))));
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(type),
        ),
        body: ListView(key: key, children: children));
  }

  void _startDrill(BuildContext context, DrillData drill) {
    AudioService.start(
        backgroundTaskEntrypoint: initDrillTask,
        androidNotificationChannelName: 'Audio Service Demo',
        notificationColor: Colors.blueAccent.value
    ).then((complete) {
      if (AudioService.running) {
        final MediaItem mediaItem = DrillProgress.fromDrillData(drill);
        log.i('Playing media item: ${mediaItem.extras}');
        AudioService.playMediaItem(mediaItem);
      } else {
        throw StateError('Failed to start AudioService.');
      }
    });
    Navigator.pushNamed(context, PracticeScreen.routeName);
  }
}
