import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ft3/practice_background.dart';

import 'album_art.dart';
import 'app_rater.dart';
import 'daily_drills_screen.dart';
import 'debug_screen.dart';
import 'drill_chooser_screen.dart';
import 'firebase_options.dart';
import 'home_screen.dart';
import 'log.dart';
import 'monthly_drills_screen.dart';
import 'practice_config_screen.dart';
import 'practice_screen.dart';
import 'progress_screen.dart';
import 'results_db.dart';
import 'results_screen.dart';
import 'static_drills.dart';

final _log = Log.get('main');

void main() async {
  stdout.writeln('FoosTrainer3 main is running');
  WidgetsFlutterBinding.ensureInitialized();
  // Start the album art load asynchronously.
  AlbumArt.load();
  _log.info('Starting ResultsDatabase.init');
  final db = ResultsDatabase.init();
  _log.info('Starting drill load');
  final drills = StaticDrills.load();
  _log.info('Creating AppRater');
  final appRater = AppRater.create();
  _log.info('Creating PracticeBackground');
  final practice = PracticeBackground.init();
  _log.info('Initializing firebase');
  final firebase =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _log.info('Running App');
  runApp(MainApp(
      await db, await drills, await appRater, await practice, await firebase));
  _log.info('App Done');
}

class MainApp extends StatelessWidget {
  static final _observer =
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);
  static final _barBackground = Colors.black87;
  static final _darkTheme = ThemeData.dark().copyWith(
    appBarTheme: AppBarTheme(backgroundColor: _barBackground),
    bottomNavigationBarTheme:
        BottomNavigationBarThemeData(backgroundColor: _barBackground),
    bottomAppBarTheme: BottomAppBarTheme(color: _barBackground),
  );

  final ResultsDatabase resultsDb;
  final StaticDrills drills;
  final AppRater appRater;
  final PracticeBackground practice;
  final FirebaseApp firebaseApp;
  final bool debugShowCheckedModeBanner;

  MainApp(this.resultsDb, this.drills, this.appRater, this.practice,
      this.firebaseApp, {this.debugShowCheckedModeBanner=false}) {
    _log.info('MainApp constructor done');
  }

  @override
  Widget build(BuildContext context) {
    _log.info('MainApp building');
    return MaterialApp(
      title: 'FoosTrainer',
      theme: _darkTheme,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      navigatorObservers: [_observer],
      initialRoute: HomeScreen.routeName,
      routes: {
        DailyDrillsScreen.routeName: (context) => DailyDrillsScreen(
            staticDrills: drills, resultsDb: resultsDb, appRater: appRater),
        DrillChooserScreen.routeName: (context) =>
            DrillChooserScreen(staticDrills: drills, appRater: appRater),
        HomeScreen.routeName: (context) => HomeScreen(
            staticDrills: drills, appRater: appRater, practice: practice),
        MonthlyDrillsScreen.routeName: (context) => MonthlyDrillsScreen(
            staticDrills: drills, resultsDb: resultsDb, appRater: appRater),
        PracticeConfigScreen.routeName: (context) =>
            PracticeConfigScreen(appRater: appRater, practice: practice),
        PracticeScreen.routeName: (context) => PracticeScreen(
            staticDrills: drills, appRater: appRater, practice: practice),
        ProgressScreen.routeName: (context) => ProgressScreen(
            staticDrills: drills, resultsDb: resultsDb, appRater: appRater),
        ResultsScreen.routeName: (context) => ResultsScreen(
            staticDrills: drills, resultsDb: resultsDb, appRater: appRater),
        DebugScreen.routeName: (context) => DebugScreen(
            staticDrills: drills, resultsDb: resultsDb, appRater: appRater),
      },
    );
  }
}
