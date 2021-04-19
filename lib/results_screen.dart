import 'package:flutter/material.dart';

import 'drill_types_screen.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'results_widget.dart';

final _log = Log.get('results_screen');

class ResultsScreen extends StatelessWidget {
  static const routeName = '/results';
  final Future<ResultsInfo> _resultsInfo;

  ResultsScreen({Key key, ResultsDatabase resultsDb})
      : _resultsInfo = resultsDb.drillsDao.f
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ResultsInfo>(
        future: _resultsInfo,
        builder: (BuildContext context, AsyncSnapshot<ResultsInfo> snapshot) {
          _log.info('Results error: ${snapshot.error}');
          ResultsInfo results = snapshot.data;
          if (results == null) {
            results = ResultsInfo(startSeconds: 0, drill: '');
          }
          _log.info('Rendering results with data ${results.encode()}');
          return Scaffold(
            appBar: MyAppBar(title: 'Drill Complete').build(context),
            body: ResultsWidget(results: results),
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
