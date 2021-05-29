import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ft3/app_bar_chip.dart';

import 'accuracy_over_time_chart.dart';
import 'chart_utils.dart' as chart_utils;
import 'drill_chooser_chip.dart';
import 'drill_data.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'reps_over_time_chart.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'spinner.dart';
import 'static_drills.dart';
import 'log.dart';
import 'progress_selection_chip.dart';

final _log = Log.get('progress_screen');

// TODO(brian):
// add option to take chart full screen??
// add per-drill type break down chart
// converge charts as much as possible between progress screen and drill
// results/history screen. Per-drill progress screen should probably show everything
// the drill results screen shows?
class ProgressScreen extends StatefulWidget {
  static const routeName = '/progress';
  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;

  static void navigate(BuildContext context, DrillData drillData) {
    Navigator.pushNamed(context, routeName, arguments: drillData);
  }

  ProgressScreen({@required this.staticDrills, @required this.resultsDb})
      : assert(staticDrills != null),
        assert(resultsDb != null);

  @override
  State<StatefulWidget> createState() => ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen> {
  Future<List<AggregatedDrillSummary>> drillHistory;
  ProgressSelection selected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DrillData drillData = ModalRoute.of(context).settings.arguments;
    selected = ProgressSelection(
        drillData: drillData, aggLevel: AggregationLevel.DAILY);
    _initFuture();
  }

  void _initFuture() {
    final drill = selected.drillData?.fullName;
    _log.info('Reloading data, aggLevel=${selected.aggLevel} drill=$drill');
    setState(() {
      drillHistory = widget.resultsDb.summariesDao.loadAggregateDrills(
          aggLevel: selected.aggLevel,
          drill: drill,
          numWeeks: chart_utils.maxWeeks,
          offset: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    _log.info('build called');
    return Scaffold(
      appBar: MyAppBar.titleWidget(
              titleWidget: _titleWidget(), includeMoreAction: false)
          .build(context),
      body: _buildBody(context),
      bottomNavigationBar: MyNavBar(location: MyNavBarLocation.progress),
    );
  }

  Widget _titleWidget() {
    return ProgressSelectionChip(
      staticDrills: widget.staticDrills,
      selected: selected,
      onProgressChange: _onProgressChange,
    );
  }

  void _onProgressChange(ProgressSelection newSelected) {
    setState(() {
      selected = newSelected;
      _initFuture();
    });
  }

  Widget _buildBody(BuildContext context) {
    return Column(children: [
      _DrillCharts(drillHistory: drillHistory),
    ]);
  }
}

class _DrillCharts extends StatefulWidget {
  final Future<List<AggregatedDrillSummary>> drillHistory;

  _DrillCharts({this.drillHistory});

  @override
  State<StatefulWidget> createState() => _DrillChartsState();
}

class _MyTab {
  final Tab tab;
  final Widget child;

  _MyTab({this.tab, this.child});
}

class _DrillChartsState extends State<_DrillCharts> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: widget.drillHistory, builder: _buildSnapshot);
  }

  Widget _buildSnapshot(BuildContext context,
      AsyncSnapshot<List<AggregatedDrillSummary>> snapshot) {
    if (snapshot.hasError) {
      return Text('${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return Spinner();
    }
    final tabs = [
      _MyTab(
          tab: Tab(text: 'Reps'),
          child: SingleChildScrollView(
              child: RepsOverTimeChart(drillHistory: snapshot.data))),
      _MyTab(
          tab: Tab(text: 'Accuracy'),
          child: SingleChildScrollView(
              child: AccuracyOverTimeChart(drillHistory: snapshot.data))),
    ];
    final tabBar = TabBar(
      tabs: tabs.map((e) => e.tab).toList(),
      physics: NeverScrollableScrollPhysics(),
    );
    final tabBarView = Expanded(
        child: TabBarView(
      children: tabs.map((e) => e.child).toList(),
      physics: NeverScrollableScrollPhysics(),
    ));
    return Expanded(
        child: DefaultTabController(
            length: tabs.length,
            child: Column(children: [tabBar, tabBarView])));
  }
}
