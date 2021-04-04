import 'package:flutter/material.dart';
import 'package:ft3/drill_types_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'log.dart';
import 'my_app_bar.dart';
import 'results_info.dart';
import 'results_widget.dart';

final _log = Log.get('results_screen');

class ResultsScreen extends StatefulWidget {
  static const routeName = '/results';
  ResultsScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Future<SharedPreferences> _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _prefs,
      builder: (BuildContext context, AsyncSnapshot<SharedPreferences> prefs) {
        _log.info('Rendering, ${prefs.connectionState}');
        return Scaffold(
          appBar: MyAppBar(title: 'Drill Complete').build(context),
          body: ResultsWidget(results: _parse(prefs.data)),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).buttonColor,
            onPressed: () => Navigator.pushReplacementNamed(
                context, DrillTypesScreen.routeName),
            child: Icon(Icons.done),
          ),
        );
      },
    );
  }

  ResultsInfo _parse(SharedPreferences prefs) {
    if (prefs != null) {
      final data = prefs.getString(ResultsInfo.prefsKey);
      _log.info('Read $data');
      if (data != null) {
        return ResultsInfo.decode(data);
      }
    }
    return ResultsInfo()
      ..drill = 'unknown'
      ..good = 0
      ..reps = 0
      ..elapsedSeconds = 0;
  }
}
