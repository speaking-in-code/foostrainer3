import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ft3/accuracy_over_time_chart.dart';

import 'chart_utils.dart' as chart_utils;
import 'drill_chooser_screen.dart';
import 'drill_data.dart';
import 'inset_divider.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'reps_over_time_chart.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'spinner.dart';
import 'static_drills.dart';
import 'log.dart';

final _log = Log.get('progress_screen');

class ProgressScreen extends StatefulWidget {
  static const routeName = '/progress';
  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;
  final _aggValue = ValueNotifier<AggregationLevel>(AggregationLevel.DAILY);
  final _drillValue = ValueNotifier<DrillData>(null);

  ProgressScreen({@required this.staticDrills, @required this.resultsDb})
      : assert(staticDrills != null),
        assert(resultsDb != null);

  @override
  State<StatefulWidget> createState() => ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen> {
  Future<List<AggregatedDrillSummary>> drillHistory;

  @override
  void initState() {
    super.initState();
    _initFuture();
    widget._drillValue.addListener(_initFuture);
    widget._aggValue.addListener(_initFuture);
  }

  void _initFuture() {
    final drill = widget._drillValue.value?.fullName;
    final aggLevel = widget._aggValue.value;
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
    return Scaffold(
      appBar: MyAppBar(title: 'Progress').build(context),
      body: _buildBody(context), // MonthlyDrillsWidget(widget.resultsDb),
      bottomNavigationBar: MyNavBar(location: MyNavBarLocation.progress),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(children: [
      _configWidget(),
      InsetDivider(thickness: 2),
      _DrillCharts(drillHistory: drillHistory),
    ]);
  }

  Widget _configWidget() {
    return Padding(
        padding: EdgeInsets.all(8),
        child: Column(children: [
          Row(children: [
            Expanded(
                child: _DrillSelector(
                    staticDrills: widget.staticDrills,
                    drillValue: widget._drillValue))
          ]),
          Row(children: [
            Expanded(child: _TimeWindowSelector(aggValue: widget._aggValue))
          ]),
        ]));
  }
}

class _DrillCharts extends StatefulWidget {
  final Future<List<AggregatedDrillSummary>> drillHistory;

  _DrillCharts({this.drillHistory});

  @override
  State<StatefulWidget> createState() => _DrillChartsState();
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
    return Expanded(
        child: SingleChildScrollView(
            child: Column(children: [
      RepsOverTimeChart(drillHistory: snapshot.data),
      InsetDivider(),
      AccuracyOverTimeChart(drillHistory: snapshot.data),
    ])));
  }
}

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

class _TimeWindowSelector extends StatefulWidget {
  final ValueNotifier<AggregationLevel> aggValue;

  _TimeWindowSelector({this.aggValue});

  @override
  State<StatefulWidget> createState() => _TimeWindowSelectorState();
}

class _TimeWindowOption {
  final AggregationLevel level;
  final String label;

  const _TimeWindowOption(this.level, this.label);
}

class _TimeWindowSelectorState extends State<_TimeWindowSelector> {
  static const options = {
    AggregationLevel.DAILY: _TimeWindowOption(AggregationLevel.DAILY, 'Daily'),
    AggregationLevel.WEEKLY:
        _TimeWindowOption(AggregationLevel.WEEKLY, 'Weekly'),
    AggregationLevel.MONTHLY:
        _TimeWindowOption(AggregationLevel.MONTHLY, 'Monthly'),
  };

  @override
  Widget build(BuildContext context) {
    return _SelectionChip(
      label: options[widget.aggValue.value].label,
      onPressed: _onTimeWindowPressed,
    );
  }

  void _onTimeWindowPressed() async {
    _TimeWindowOption chosen = await showModalBottomSheet(
        context: context, builder: _timeWindowChooser);
    if (chosen == null) {
      return;
    }
    setState(() {
      widget.aggValue.value = chosen.level;
    });
  }

  Widget _timeWindowChooser(BuildContext context) {
    final List<Widget> tiles = [
      ListTile(title: Text('Time Window')),
    ];
    final groupValue = options[widget.aggValue.value];
    tiles.addAll(options.values.map((_TimeWindowOption option) {
      return RadioListTile<_TimeWindowOption>(
        title: Text(option.label),
        value: option,
        groupValue: groupValue,
        onChanged: _onChosen,
      );
    }));
    return ListView(children: tiles);
  }

  void _onChosen(_TimeWindowOption selected) {
    Navigator.pop(context, selected);
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
    return _SelectionChip(
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
}

class _SelectionChip extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  _SelectionChip({this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InputChip(
        label: Row(
          children: [Text(label, overflow: TextOverflow.ellipsis)],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        onSelected: (_) => this.onPressed(),
        selected: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        onDeleted: this.onPressed,
        deleteIcon: Icon(Icons.arrow_drop_down));
  }
}

// The plan:
// display a row of chips at the top.
// - drill selection chip: defaults to all drills. Clicking leads to modal dialog
//   with a long list of drills to select from.
// - time window chip: defaults to daily. Clicking leads to modal dialog with daily/weekly/monthly selection.
//
// Display charts in scroll view
// - practice time for (drill) by (window)
// - practice reps for (drill) by (window)
// - accuracy for (drill) by (windows)
//
// If drill selected: FAB for practicing drill, leads to drill config screen
//
