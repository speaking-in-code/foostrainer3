import 'package:flutter/material.dart';

import 'drill_data.dart';
import 'drill_types_screen.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'results_widget.dart';
import 'spinner.dart';
import 'static_drills.dart';

final _log = Log.get('results_screen');

class _Args {
  final int drillId;
  final DrillData drillData;

  _Args(this.drillId, this.drillData);
}

class ResultsScreen extends StatelessWidget {
  static const routeName = '/results';

  static void pushReplacement(
      BuildContext context, int drillId, DrillData drillData) {
    Navigator.pushReplacementNamed(context, routeName,
        arguments: _Args(drillId, drillData));
  }

  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;

  ResultsScreen({@required this.staticDrills, @required this.resultsDb});

  @override
  Widget build(BuildContext context) {
    final _Args args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: MyAppBar(title: 'Results').build(context),
      body: _LoadedResultsScreen(staticDrills, resultsDb, args.drillId),
      bottomNavigationBar: MyNavBar(
          location: MyNavBarLocation.PRACTICE, drillData: args.drillData),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).buttonColor,
        onPressed: () =>
            Navigator.pushReplacementNamed(context, DrillTypesScreen.routeName),
        child: Icon(Icons.done),
      ),
    );
  }
}

class _LoadedResultsScreen extends StatefulWidget {
  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;
  final int drillId;

  _LoadedResultsScreen(this.staticDrills, this.resultsDb, this.drillId);

  @override
  State<StatefulWidget> createState() => _LoadedResultsScreenState();
}

class _LoadedResultsScreenState extends State<_LoadedResultsScreen> {
  Future<DrillSummary> _summary;

  @override
  void initState() {
    super.initState();
    _summary = widget.resultsDb.summariesDao
        .loadDrill(widget.resultsDb, widget.drillId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DrillSummary>(
        future: _summary,
        builder: (BuildContext context, AsyncSnapshot<DrillSummary> snapshot) {
          if (snapshot.hasData) {
            return ResultsWidget(
                staticDrills: widget.staticDrills, summary: snapshot.data);
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          } else {
            return Spinner();
          }
        });
  }
}
