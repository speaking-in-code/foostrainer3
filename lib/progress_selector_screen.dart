import 'package:flutter/material.dart';

import 'drill_chooser_widget.dart';
import 'drill_data.dart';
import 'my_app_bar.dart';
import 'results_db.dart';
import 'static_drills.dart';

class ProgressOptions {
  final DrillData drillData;
  final AggregationLevel aggregationLevel;

  ProgressOptions({this.drillData, this.aggregationLevel});
}

class ProgressSelectorScreen extends StatefulWidget {
  static Future<ProgressOptions> startDialog(BuildContext context,
      {@required StaticDrills staticDrills,
      @required ProgressOptions selected,
      bool allowAll = false}) async {
    ProgressOptions chosen = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => ProgressSelectorScreen(
                  staticDrills: staticDrills,
                  selected: selected,
                  allowAll: allowAll,
                )));
    return chosen;
  }

  final ProgressOptions selected;
  final StaticDrills staticDrills;

  const ProgressSelectorScreen(
      {@required this.staticDrills,
      @required this.selected,
      bool allowAll = false})
      : assert(staticDrills != null),
        assert(selected != null);

  @override
  State<StatefulWidget> createState() => _ProgressSelectorScreenState();
}

class _ProgressSelectorScreenState extends State<ProgressSelectorScreen> {
  static const kAggregationId = 0;
  static const kDrillId = 1;

  static const _aggOptions = {
    AggregationLevel.DAILY: _TimeWindowOption(AggregationLevel.DAILY, 'Daily'),
    AggregationLevel.WEEKLY:
        _TimeWindowOption(AggregationLevel.WEEKLY, 'Weekly'),
    AggregationLevel.MONTHLY:
        _TimeWindowOption(AggregationLevel.MONTHLY, 'Monthly'),
  };

  DrillData drillData;
  AggregationLevel aggregationLevel;

  @override
  void initState() {
    super.initState();
    drillData = widget.selected.drillData;
    aggregationLevel = widget.selected.aggregationLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Progress Options').build(context),
      body: _expansionPanels(),
      floatingActionButton: FloatingActionButton(
        onPressed: _onShowChart,
        backgroundColor: Theme.of(context).buttonColor,
        child: Icon(Icons.show_chart),
      ),
    );
  }

  void _onShowChart() {
    Navigator.pop(
        context,
        ProgressOptions(
            drillData: drillData, aggregationLevel: aggregationLevel));
  }

  Widget _expansionPanels() {
    List<ExpansionPanelRadio> children = [
      _aggregationPicker(),
      _drillPicker(),
    ];
    return SingleChildScrollView(
      child: Container(
        child: ExpansionPanelList.radio(
          children: children,
        ),
      ),
    );
  }

  ExpansionPanelRadio _aggregationPicker() {
    return ExpansionPanelRadio(
        value: kAggregationId,
        headerBuilder: _aggregationHeader,
        canTapOnHeader: true,
        body: Column(
            children: _aggOptions.values.map(_makeAggregationOption).toList()));
  }

  Widget _aggregationHeader(BuildContext context, bool isExpanded) {
    final label = _aggOptions[aggregationLevel].label;
    return ListTile(
      title: Text('Time Range: $label'),
    );
  }

  Widget _makeAggregationOption(_TimeWindowOption option) {
    return RadioListTile<AggregationLevel>(
      activeColor: Theme.of(context).buttonColor,
      title: Text(option.label),
      value: option.level,
      groupValue: aggregationLevel,
      onChanged: (AggregationLevel newLevel) {
        setState(() {
          aggregationLevel = newLevel;
        });
      },
    );
  }

  ExpansionPanelRadio _drillPicker() {
    return ExpansionPanelRadio(
        value: kDrillId,
        headerBuilder: _drillHeader,
        canTapOnHeader: true,
        body: SingleChildScrollView(
            child: DrillChooserWidget(
                staticDrills: widget.staticDrills,
                onDrillChosen: (DrillData selected) {
                  setState(() {
                    drillData = selected;
                  });
                },
                selected: drillData,
                allowAll: true,
                shrinkWrap: true,
                primaryScroll: false)));
  }

  Widget _drillHeader(BuildContext context, bool isExpanded) {
    String title = 'All Drills';
    Text subtitle;
    if (drillData != null) {
      title = drillData.type;
      subtitle = Text(drillData.name);
    }
    return ListTile(title: Text(title), subtitle: subtitle);
  }
}

class _TimeWindowOption {
  final AggregationLevel level;
  final String label;

  const _TimeWindowOption(this.level, this.label);
}
