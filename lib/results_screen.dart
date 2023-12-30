import 'package:flutter/material.dart';

import 'app_rater.dart';
import 'drill_data.dart';
import 'drill_performance_table.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'practice_config_screen.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'spinner.dart';
import 'static_drills.dart';
import 'stats_grid_widget.dart';

final _log = Log.get('results_screen');

class ResultsScreenArgs {
  final int drillId;
  final DrillData drillData;

  ResultsScreenArgs(this.drillId, this.drillData);
}

class ResultsScreen extends StatelessWidget {
  static const routeName = '/results';

  static void push(BuildContext context, int drillId, DrillData drillData) =>
      Navigator.pushNamed(context, routeName,
          arguments: ResultsScreenArgs(drillId, drillData));

  static void pushReplacement(
      BuildContext context, int drillId, DrillData drillData) {
    Navigator.pushReplacementNamed(context, routeName,
        arguments: ResultsScreenArgs(drillId, drillData));
  }

  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;
  final AppRater appRater;

  ResultsScreen(
      {required this.staticDrills,
      required this.resultsDb,
      required this.appRater});

  @override
  Widget build(BuildContext context) {
    final ResultsScreenArgs args =
        ModalRoute.of(context)!.settings.arguments as ResultsScreenArgs;
    return _LoadedResultsScreen(resultsDb, args, appRater);
  }
}

class _LoadedResultsScreen extends StatefulWidget {
  final ResultsDatabase resultsDb;
  final ResultsScreenArgs args;
  final AppRater appRater;

  _LoadedResultsScreen(this.resultsDb, this.args, this.appRater);

  @override
  State<StatefulWidget> createState() => _LoadedResultsScreenState();
}

class _LoadedResultsScreenState extends State<_LoadedResultsScreen> {
  late Future<DrillSummary?> _summary;

  @override
  void initState() {
    super.initState();
    _summary = widget.resultsDb.summariesDao
        .loadDrill(widget.resultsDb, widget.args.drillId);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted && widget.appRater.shouldRequestReview) {
        widget.appRater.requestReview();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DrillSummary?>(
        future: _summary,
        builder: (BuildContext context, AsyncSnapshot<DrillSummary?> snapshot) {
          if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return Spinner();
          }
          return _buildScaffold(snapshot.data!);
        });
  }

  Widget _buildScaffold(DrillSummary summary) {
    return Scaffold(
      appBar: MyAppBar.drillTitle(
              drillData: widget.args.drillData, appRater: widget.appRater)
          .build(context),
      body: _summaryCard(summary),
      floatingActionButton: _playButton(),
      bottomNavigationBar:
          MyNavBar.forDrillNav(MyNavBarLocation.monthly, widget.args.drillData),
    );
  }

  Widget _playButton() {
    return FloatingActionButton(
      child: Icon(Icons.play_arrow),
      mini: true,
      onPressed: () =>
          PracticeConfigScreen.navigate(context, widget.args.drillData),
    );
  }

  Widget _summaryCard(DrillSummary summary) {
    return ListView(children: [
      // DrillDescriptionTile(drillData: widget.args.drillData),
      StatsGridWidget(summary: summary, drillData: widget.args.drillData),
      DrillPerformanceTable(summary: summary),
      // Add space at end to display fab.
      SizedBox(height: 56.0),
    ]);
  }
}
