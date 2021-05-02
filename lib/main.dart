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
import 'results_db.dart';
import 'results_screen.dart';
import 'static_drills.dart';
import 'stats_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Start the album art load asynchronously.
  AlbumArt.load();
  final db = ResultsDatabase.init();
  final drills = StaticDrills.load();
  runApp(MainApp(await db, await drills));
}

class MainApp extends StatelessWidget {
  static final _analytics = FirebaseAnalytics();
  static final _observer = FirebaseAnalyticsObserver(analytics: _analytics);
  final ResultsDatabase resultsDb;
  final StaticDrills drills;

  const MainApp(this.resultsDb, this.drills);

  // Audio service wraps the entire application, so all routes can maintain a
  // connection to the service.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoosTrainer',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorObservers: <NavigatorObserver>[_observer],
      initialRoute: DrillTypesScreen.routeName,
      routes: {
        DrillTypesScreen.routeName: (context) =>
            AudioServiceWidget(child: DrillTypesScreen(drills)),
        DrillListScreen.routeName: (context) => DrillListScreen(),
        PracticeConfigScreen.routeName: (context) => PracticeConfigScreen(),
        PracticeScreen.routeName: (context) => PracticeScreen(),
        ResultsScreen.routeName: (context) =>
            ResultsScreen(resultsDb: resultsDb),
        DebugScreen.routeName: (context) => DebugScreen(resultsDb, drills),
        StatsScreen.routeName: (context) => StatsScreen(resultsDb),
      },
    );
  }
}
