import 'package:audio_service/audio_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';

import 'album_art.dart';
import 'debug_screen.dart';
import 'drill_list_screen.dart';
import 'drill_types_screen.dart';
import 'practice_config_screen.dart';
import 'practice_screen.dart';

void main() {
  // Start the album art load asynchronously.
  WidgetsFlutterBinding.ensureInitialized();
  AlbumArt.load();

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  static final _analytics = FirebaseAnalytics();
  static final _observer = FirebaseAnalyticsObserver(analytics: _analytics);

  // Audio service wraps the entire application, so all routes can maintain a
  // connection to the service.
  @override
  Widget build(BuildContext context) {
    return AudioServiceWidget(
        child: MaterialApp(
      title: 'FoosTrainer',
      theme: ThemeData(
        brightness: Brightness.dark,
        // primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorObservers: <NavigatorObserver>[_observer],
      initialRoute: DrillTypesScreen.routeName,
      routes: {
        DrillTypesScreen.routeName: (context) => DrillTypesScreen(),
        DrillListScreen.routeName: (context) => DrillListScreen(),
        PracticeConfigScreen.routeName: (context) => PracticeConfigScreen(),
        PracticeScreen.routeName: (context) => PracticeScreen(),
        DebugScreen.routeName: (context) => DebugScreen(),
      },
    ));
  }
}
