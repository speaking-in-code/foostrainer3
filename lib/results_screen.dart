import 'package:flutter/material.dart';

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

// Make the bottom nav bar here smarter. Should be a choice between details, history
// and practice, I think, with practice probably on bottom right. Highlight
// whichever one we're on.
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

  ResultsScreen({@required this.staticDrills, @required this.resultsDb});

  @override
  Widget build(BuildContext context) {
    final ResultsScreenArgs args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: MyAppBar(title: 'Results').build(context),
      body: _LoadedResultsScreen(resultsDb, args.drillData, args.drillId),
      bottomNavigationBar: MyNavBar(
          location: MyNavBarLocation.monthly, drillData: args.drillData),
    );
  }

  Widget _replayButton() {
    return FloatingActionButton(child: Icon(Icons.replay));
  }
}

class _LoadedResultsScreen extends StatefulWidget {
  final ResultsDatabase resultsDb;
  final DrillData drillData;
  final int drillId;

  _LoadedResultsScreen(this.resultsDb, this.drillData, this.drillId);

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
          if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return Spinner();
          }
          return _summaryCard(snapshot.data);
        });
  }

  Widget _summaryCard(DrillSummary summary) {
    return ListView(children: [
      Card(
        child: ListTile(
          title: Text(widget.drillData.type),
          subtitle: Text(widget.drillData.name),
          trailing: IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: _onPlay,
          ),
        ),
      ),
      Card(
          child:
              StatsGridWidget(summary: summary, drillData: widget.drillData)),
      Card(child: DrillPerformanceTable(summary: summary)),
    ]);
  }

  void _onPlay() {
    PracticeConfigScreen.navigate(context, widget.drillData);
  }
}
