import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ft3/accuracy_over_time_chart.dart';

import 'chart_utils.dart' as chart_utils;
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'progress_selector_screen.dart';
import 'reps_over_time_chart.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'spinner.dart';
import 'static_drills.dart';
import 'log.dart';
import 'titled_section.dart';

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

  ProgressScreen({@required this.staticDrills, @required this.resultsDb})
      : assert(staticDrills != null),
        assert(resultsDb != null);

  @override
  State<StatefulWidget> createState() => ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen> {
  Future<List<AggregatedDrillSummary>> drillHistory;
  ProgressOptions options = ProgressOptions(
      drillData: null, aggregationLevel: AggregationLevel.DAILY);

  @override
  void initState() {
    super.initState();
    _initFuture();
  }

  void _initFuture() {
    final drill = options.drillData?.fullName;
    final aggLevel = options.aggregationLevel;
    _log.info('Reloading data, aggLevel=$aggLevel drill=$drill');
    setState(() {
      drillHistory = widget.resultsDb.summariesDao.loadAggregateDrills(
          aggLevel: aggLevel,
          drill: drill,
          numWeeks: chart_utils.maxWeeks,
          offset: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      IconButton(
        icon: const Icon(Icons.search),
        tooltip: 'Select Drills',
        onPressed: () => _onSelectDrills(context),
      )
    ];
    return Scaffold(
      appBar: MyAppBar(title: 'Progress', actions: actions).build(context),
      body: _buildBody(context), // MonthlyDrillsWidget(widget.resultsDb),
      bottomNavigationBar: MyNavBar(location: MyNavBarLocation.progress),
    );
  }

  void _onSelectDrills(BuildContext context) async {
    ProgressOptions chosen = await ProgressSelectorScreen.startDialog(context,
        staticDrills: widget.staticDrills, selected: options, allowAll: true);
    if (chosen != null) {
      setState(() {
        options = chosen;
        _initFuture();
      });
    }
  }

  Widget _buildBody(BuildContext context) {
    String title = 'All Drills';
    if (options.drillData != null) {
      title = '${options.drillData.type}: ${options.drillData.name}';
    }
    return Padding(
        padding: EdgeInsets.only(top: 8),
        child: TitledSection(
            title: title, child: _DrillCharts(drillHistory: drillHistory)));
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

/*
class _SelectedDrill extends StatefulWidget {
  final ValueNotifier<DrillData> drillValue;
  _SelectedDrill({this.drillValue});

  @override
  State<StatefulWidget> createState() => _SelectedDrillState();
}

class _SelectedDrillState extends State<_SelectedDrill> {
  @override
  void initState() {
    super.initState();
    widget.drillValue.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Drill: All';
    Text subtitle;
    DrillData drillData = widget.drillValue.value;
    if (drillData != null) {
      title = 'Drill: ${drillData.type}';
      subtitle = Text(widget.drillValue.value.name);
    }
    return ListTile(title: Text(title), subtitle: subtitle);
  }
}

class _DrillSelector extends StatefulWidget {
  final StaticDrills staticDrills;
  final ValueNotifier<DrillData> drillValue;

  _DrillSelector({this.staticDrills, this.drillValue});

  @override
  State<StatefulWidget> createState() => _DrillSelectorState();
}

class _DrillSelectorState extends State<_DrillSelector> {
  DrillData selected;

  @override
  Widget build(BuildContext context) {
    String label = 'All Drills';
    if (selected != null) {
      label = '${selected.type}: ${selected.name}';
    }
    return SelectionChip(
      label: label,
      onPressed: _onDrillSelectorPressed,
    );
  }

  void _onDrillSelectorPressed() async {
    DrillData chosen = await DrillChooserScreen.startDialog(context,
        staticDrills: widget.staticDrills, selected: selected, allowAll: true);
    _log.info('Setting new value of ${chosen?.fullName}');
    widget.drillValue.value = chosen;
    setState(() {
      selected = chosen;
    });
  }
}*/
