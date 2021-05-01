import 'package:flutter/material.dart';

import 'drill_types_screen.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'results_widget.dart';

final _log = Log.get('results_screen');

class ResultsScreen extends StatelessWidget {
  static const routeName = '/results';
  final Future<DrillSummary> _summary;

  ResultsScreen({Key key, ResultsDatabase resultsDb, int drillId})
      : _summary = resultsDb.summariesDao.loadDrill(resultsDb, drillId),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DrillSummary>(
        future: _summary,
        builder: (BuildContext context, AsyncSnapshot<DrillSummary> snapshot) {
          _log.info('Results error: ${snapshot.error}');
          DrillSummary results = snapshot.data;
          if (results == null) {
            results = DrillSummary(
                drill: StoredDrill(drill: '', elapsedSeconds: 0), reps: 0);
          }
          return Scaffold(
            appBar: MyAppBar(title: 'Drill Complete').build(context),
            body: ResultsWidget(summary: results),
            bottomNavigationBar: MyNavBar(MyNavBarLocation.PRACTICE),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Theme.of(context).buttonColor,
              onPressed: () => Navigator.pushReplacementNamed(
                  context, DrillTypesScreen.routeName),
              child: Icon(Icons.done),
            ),
          );
        });
  }
}
