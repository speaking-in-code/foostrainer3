import 'package:audio_service/audio_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';

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
  WidgetsFlutterBinding.ensureInitialized();
  // Start the album art load asynchronously.
  AlbumArt.load();
  _log.info('Starting ResultsDatabase.init');
  final db = ResultsDatabase.init();
  _log.info('Starting drill load');
  final drills = StaticDrills.load();
  _log.info('Creating AppRater');
  final appRater = AppRater.create();
  _log.info('Initializing firebase');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _log.info('Running App');
  runApp(MainApp(await db, await drills, await appRater));
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

  MainApp(this.resultsDb, this.drills, this.appRater) {
    _log.info('MainApp constructor done');
  }

  // Audio service wraps the entire application, so all routes can maintain a
  // connection to the service.
  @override
  Widget build(BuildContext context) {
    _log.info('MainApp building');
    return MaterialApp(
      title: 'FoosTrainer',
      theme: _darkTheme,
      navigatorObservers: [_observer],
      initialRoute: HomeScreen.routeName,
      routes: {
        DailyDrillsScreen.routeName: (context) => DailyDrillsScreen(
            staticDrills: drills, resultsDb: resultsDb, appRater: appRater),
        DrillChooserScreen.routeName: (context) =>
            DrillChooserScreen(staticDrills: drills, appRater: appRater),
        HomeScreen.routeName: (context) => AudioServiceWidget(
            child: HomeScreen(staticDrills: drills, appRater: appRater)),
        MonthlyDrillsScreen.routeName: (context) => MonthlyDrillsScreen(
            staticDrills: drills, resultsDb: resultsDb, appRater: appRater),
        PracticeConfigScreen.routeName: (context) =>
            PracticeConfigScreen(appRater: appRater),
        PracticeScreen.routeName: (context) =>
            PracticeScreen(staticDrills: drills, appRater: appRater),
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
