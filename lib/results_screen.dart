import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'aggregated_drill_summary.dart';
import 'chart_utils.dart' as chart_utils;
import 'drill_data.dart';
import 'drill_details_widget.dart';
import 'duration_formatter.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'percent_formatter.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'spinner.dart';
import 'static_drills.dart';

final _log = Log.get('results_screen');

class _Args {
  final int drillId;
  final DrillData drillData;

  _Args(this.drillId, this.drillData);
}

// TODO: brian
// - make it possible to navigate this screen again, right now it is unreachable
// except by practicing.
// - use the button row from the per-drill stats screen (History/Practice) instead
// of the FAB.
// - make the accuracy bar chart have labels
//
// For navigation, I think what we want is:
// practice takes you to the all-drill practice screen.
// stats takes you to the per-drill stats screen.
// ... wtf does History and Practice do...?   I dunno. I just don't like the
// FAB, it doesn't make sense here. Or maybe it should be a circle arrow, to
// indicate it's repeating the drill...?
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
          if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return Spinner();
          }
          final summary = snapshot.data;
          final drillData = widget.staticDrills.getDrill(summary.drill.drill);
          final perAction = AggregatedDrillSummary.fromSummary(summary);
          final children = [
            _summaryCard(summary, drillData),
          ];
          if (summary.drill.tracking) {
            children.add(_drillDetails(perAction));
          }
          return ListView(children: children);
        });
  }

  Widget _summaryCard(DrillSummary summary, DrillData drillData) {
    return Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: const EdgeInsets.all(8),
          child: Text(drillData.name,
              style: Theme.of(context).textTheme.headline6)),
      Center(
          child: GridView.count(
        childAspectRatio: 2,
        crossAxisCount: 2,
        shrinkWrap: true,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          _reps(summary),
          _duration(summary),
          _success(summary),
          _accuracy(summary),
        ],
      )),
    ]));
  }

  TextStyle get _labelStyle => Theme.of(context).textTheme.subtitle1;
  TextStyle get _dataStyle => Theme.of(context).textTheme.headline5;

  Widget _duration(DrillSummary summary) {
    return _labeledData(
        label: 'Duration',
        data: DurationFormatter.format(summary.drill.elapsed));
  }

  Widget _reps(DrillSummary summary) {
    return _labeledData(label: 'Reps', data: '${summary.reps}');
  }

  Widget _success(DrillSummary summary) {
    return _labeledData(
        label: 'Success',
        data: summary.good != null ? '${summary.good}' : '--');
  }

  Widget _accuracy(DrillSummary summary) {
    return _labeledData(
        label: 'Accuracy',
        data: PercentFormatter.formatAccuracy(
            trackedReps: summary.reps, trackedGood: summary.good));
  }

  Widget _labeledData({String label, String data}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$label', style: _labelStyle),
        Text('$data', style: _dataStyle),
      ],
    );
  }

  Widget _drillDetails(AggregatedDrillSummary perAction) {
    List<AggregatedAction> data = perAction.actions.values.toList();
    data.forEach((element) {
      _log.info('Accuracy: ${element.action} => ${element.accuracy}');
    });
    final accuracy = charts.Series<AggregatedAction, String>(
      id: 'accuracy',
      domainFn: (AggregatedAction action, _) => action.action,
      measureFn: (AggregatedAction action, _) => action.accuracy,
      data: data,
    );
    int desiredLegendRows = 2;
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      desiredLegendRows = 1;
    }
    final chart = charts.BarChart(
      [accuracy],
      animate: true,
      //behaviors: [
      // charts.ChartTitle('ewrwe', titleStyleSpec: chart_utils.titleStyle),
      //],
      primaryMeasureAxis: new charts.PercentAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
        labelStyle: chart_utils.axisLabelStyle,
        lineStyle: chart_utils.axisLineStyle,
      )),
    );
    return Card(child: chart_utils.paddedChart(chart));
  }
}
