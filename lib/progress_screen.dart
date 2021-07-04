import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'drill_list_widget.dart';

import 'accuracy_over_time_chart.dart';
import 'chart_utils.dart' as chart_utils;
import 'drill_data.dart';
import 'keys.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'no_drills_widget.dart';
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

  ProgressScreen({required this.staticDrills, required this.resultsDb});

  @override
  State<StatefulWidget> createState() => ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen> {
  late Future<List<AggregatedDrillSummary>> drillHistory;
  late ProgressSelection selected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DrillData? drillData =
        ModalRoute.of(context)!.settings.arguments as DrillData?;
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
      appBar: MyAppBar.titleWidget(titleWidget: _titleWidget()).build(context),
      body: _buildBody(context),
      bottomNavigationBar:
          MyNavBar.forDrillNav(MyNavBarLocation.progress, selected.drillData),
    );
  }

  Widget _titleWidget() {
    return ProgressSelectionChip(
      staticDrills: widget.staticDrills,
      selected: selected,
      onProgressChange: _onProgressChange,
    );
  }

  void _onProgressChange(ProgressSelection? newSelected) {
    setState(() {
      selected = newSelected!;
      _initFuture();
    });
  }

  Widget _buildBody(BuildContext context) {
    return Column(children: [
      _DrillTabs(
          resultsDb: widget.resultsDb,
          staticDrills: widget.staticDrills,
          drillData: selected.drillData,
          drillHistory: drillHistory,
          aggLevel: selected.aggLevel)
    ]);
  }
}

class _DrillTabs extends StatefulWidget {
  final ResultsDatabase resultsDb;
  final StaticDrills staticDrills;
  final DrillData? drillData;
  final Future<List<AggregatedDrillSummary>> drillHistory;
  final AggregationLevel aggLevel;

  _DrillTabs(
      {required this.resultsDb,
      required this.staticDrills,
      this.drillData,
      required this.drillHistory,
      required this.aggLevel});

  @override
  State<StatefulWidget> createState() => _DrillTabsState();
}

class _MyTab {
  final Tab tab;
  final Widget child;

  _MyTab({required this.tab, required this.child});
}

class _DrillTabsState extends State<_DrillTabs> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: widget.drillHistory, builder: _buildSnapshot);
  }

  Widget _buildSnapshot(BuildContext context,
      AsyncSnapshot<List<AggregatedDrillSummary>> snapshot) {
    _log.info('Rebuilding tabs, drill is ${widget.drillData?.fullName}');
    if (snapshot.hasError) {
      return Text('${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return Spinner();
    }
    Widget reps;
    Widget accuracy;
    Widget log;
    if (snapshot.data!.isNotEmpty) {
      reps = SingleChildScrollView(
          child: RepsOverTimeChart(
              aggLevel: widget.aggLevel, drillHistory: snapshot.data!));
      accuracy = SingleChildScrollView(
          child: AccuracyOverTimeChart(
              aggLevel: widget.aggLevel, drillHistory: snapshot.data!));
      log = DrillListWidget(
          key: UniqueKey(),
          resultsDb: widget.resultsDb,
          staticDrills: widget.staticDrills,
          drillFullName: widget.drillData?.fullName);
    } else {
      reps = NoDrillsWidget(
          staticDrills: widget.staticDrills, drillData: widget.drillData);
      accuracy = reps;
      log = reps;
    }
    final tabs = [
      _MyTab(tab: Tab(text: 'Reps'), child: reps),
      _MyTab(
          tab: Tab(key: Key(Keys.accuracyTabKey), text: 'Accuracy'),
          child: accuracy),
      _MyTab(tab: Tab(text: 'Log'), child: log),
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
