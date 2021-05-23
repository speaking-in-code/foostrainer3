import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'chart_utils.dart' as chart_utils;
import 'drill_data.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'percent_formatter.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'spinner.dart';
import 'static_drills.dart';
import 'stats_grid_widget.dart';
import 'titled_card.dart';

final _log = Log.get('results_screen');

class _Args {
  final int drillId;
  final DrillData drillData;

  _Args(this.drillId, this.drillData);
}

// Make the bottom nav bar here smarter. Should be a choice between details, history
// and practice, I think, with practice probably on bottom right. Highlight
// whichever one we're on.
class ResultsScreen extends StatelessWidget {
  static const routeName = '/results';

  static void push(BuildContext context, int drillId, DrillData drillData) =>
      Navigator.pushNamed(context, routeName,
          arguments: _Args(drillId, drillData));

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
          final children = [
            _summaryCard(summary, drillData),
          ];
          if (summary.drill.tracking) {
            children.add(_accuracyChart(summary, drillData));
          }
          return ListView(children: children);
        });
  }

  Widget _summaryCard(DrillSummary summary, DrillData drillData) {
    return TitledCard(
        title: drillData.name,
        child: StatsGridWidget(summary: summary, drillData: drillData));
  }

  List<_PerActionAccuracy> _perActionAccuracy(
      DrillSummary summary, DrillData drillData) {
    final perAction = drillData.actions.map((ActionData action) {
      double accuracy = summary.actions[action.label]?.accuracy;
      return _PerActionAccuracy(action.label, accuracy);
    });
    return perAction.toList();
  }

  // Reorder entries here by order in StaticDrills, not alphabetical order.
  Widget _accuracyChart(DrillSummary summary, DrillData drillData) {
    List<_PerActionAccuracy> data = _perActionAccuracy(summary, drillData);
    final accuracy = charts.Series<_PerActionAccuracy, String>(
      id: 'accuracy',
      domainFn: (_PerActionAccuracy action, _) => action.action,
      measureFn: (_PerActionAccuracy action, _) => action.accuracy,
      data: data,
      labelAccessorFn: (_PerActionAccuracy action, _) =>
          PercentFormatter.format(action.accuracy),
    );
    final chart = charts.BarChart(
      [accuracy],
      animate: true,
      barRendererDecorator: charts.BarLabelDecorator<String>(),
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: chart_utils.axisLabelStyle,
        ),
      ),
    );
    return TitledCard(title: 'Accuracy', child: chart_utils.paddedChart(chart));
  }
}

class _PerActionAccuracy {
  final String action;
  final double accuracy;

  _PerActionAccuracy(this.action, this.accuracy);
}
