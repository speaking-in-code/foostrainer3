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

  final ResultsDatabase resultsDb;

  ResultsScreen(this.resultsDb);

  @override
  Widget build(BuildContext context) {
    final drillId = ModalRoute.of(context).settings.arguments;
    return _LoadedResultsScreen(resultsDb, drillId);
  }
}

class _LoadedResultsScreen extends StatefulWidget {
  final ResultsDatabase resultsDb;
  final int drillId;

  _LoadedResultsScreen(this.resultsDb, this.drillId);

  @override
  State<StatefulWidget> createState() => _LoadedResultsScreenState();
}

class _LoadedResultsScreenState extends State<_LoadedResultsScreen> {
  Future<DrillSummary> _summary;

  @override
  void initState() {
    super.initState();
    _summary = Future.delayed(
        Duration(seconds: 5),
        () => widget.resultsDb.summariesDao
            .loadDrill(widget.resultsDb, widget.drillId));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DrillSummary>(
        future: _summary,
        builder: (BuildContext context, AsyncSnapshot<DrillSummary> snapshot) {
          _log.info('Results error: ${snapshot.error}');
          String title;
          Widget body;
          if (snapshot.hasData) {
            body = ResultsWidget(summary: snapshot.data);
            title = snapshot.data.drill.drill;
          } else if (snapshot.hasError) {
            body = Text('${snapshot.error}');
            title = 'Error';
          } else {
            body = CircularProgressIndicator(semanticsLabel: 'Loading Drill');
            title = 'Loading';
          }
          return Scaffold(
            appBar: MyAppBar(title: title).build(context),
            body: body,
            bottomNavigationBar: MyNavBar(location: MyNavBarLocation.PRACTICE),
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
