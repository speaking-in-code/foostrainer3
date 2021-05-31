import 'package:audio_service/audio_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';

import 'album_art.dart';
import 'daily_drills_screen.dart';
import 'debug_screen.dart';
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
  final db = ResultsDatabase.init();
  final drills = StaticDrills.load();
  runApp(MainApp(await db, await drills));
}

class MainApp extends StatelessWidget {
  static final _analytics = FirebaseAnalytics();
  static final _observer = FirebaseAnalyticsObserver(analytics: _analytics);
  static final _barBackground = Colors.black87;
  static final _darkTheme = ThemeData.dark().copyWith(
    appBarTheme: AppBarTheme(backgroundColor: _barBackground),
    bottomNavigationBarTheme:
        BottomNavigationBarThemeData(backgroundColor: _barBackground),
    bottomAppBarTheme: BottomAppBarTheme(color: _barBackground),
  );
  final ResultsDatabase resultsDb;
  final StaticDrills drills;

  const MainApp(this.resultsDb, this.drills);

  // Audio service wraps the entire application, so all routes can maintain a
  // connection to the service.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoosTrainer',
      theme: _darkTheme,
      navigatorObservers: <NavigatorObserver>[_observer],
      initialRoute: HomeScreen.routeName,
      routes: {
        DailyDrillsScreen.routeName: (context) =>
            DailyDrillsScreen(staticDrills: drills, resultsDb: resultsDb),
        HomeScreen.routeName: (context) =>
            AudioServiceWidget(child: HomeScreen(staticDrills: drills)),
        MonthlyDrillsScreen.routeName: (context) =>
            MonthlyDrillsScreen(resultsDb: resultsDb),
        PracticeConfigScreen.routeName: (context) => PracticeConfigScreen(),
        PracticeScreen.routeName: (context) =>
            PracticeScreen(staticDrills: drills),
        ProgressScreen.routeName: (context) =>
            ProgressScreen(staticDrills: drills, resultsDb: resultsDb),
        ResultsScreen.routeName: (context) =>
            ResultsScreen(staticDrills: drills, resultsDb: resultsDb),
        DebugScreen.routeName: (context) =>
            DebugScreen(staticDrills: drills, resultsDb: resultsDb),
      },
    );
  }
}
