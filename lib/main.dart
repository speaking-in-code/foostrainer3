import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:ft3/drill_list_screen.dart';

import 'practice_screen.dart';
import 'drill_types_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Audio service wraps the entire application, so all routes can maintain a
  // connection to the service.
  @override
  Widget build(BuildContext context) {
    return AudioServiceWidget(child: MaterialApp(
      title: 'FoosTrainer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: DrillTypesScreen.routeName,
      routes: {
        DrillTypesScreen.routeName: (context) => DrillTypesScreen(),
        DrillListScreen.routeName: (context) => DrillListScreen(),
        PracticeScreen.routeName: (context) => PracticeScreen(),
      },
    ));
  }
}
