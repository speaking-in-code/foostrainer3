import 'package:flutter/material.dart';
import 'package:ft3/titled_card.dart';

import 'drill_chooser_screen.dart';
import 'drill_data.dart';
import 'my_app_bar.dart';
import 'my_nav_bar.dart';
import 'results_db.dart';
import 'static_drills.dart';
import 'log.dart';

final _log = Log.get('progress_screen');

class ProgressScreen extends StatelessWidget {
  static const routeName = '/progress';
  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;
  final _drillValue = ValueNotifier<DrillData>(null);

  ProgressScreen({@required this.staticDrills, @required this.resultsDb})
      : assert(staticDrills != null),
        assert(resultsDb != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Progress').build(context),
      body: _buildBody(context), // MonthlyDrillsWidget(widget.resultsDb),
      bottomNavigationBar: MyNavBar(location: MyNavBarLocation.progress),
    );
  }

  Widget _buildBody(BuildContext context) {
    final buttons = ButtonBar(alignment: MainAxisAlignment.end, children: [
      _TimeWindowSelector(),
      _buildDrillSelector(),
    ]);
    return SingleChildScrollView(
        child: Column(children: [
      Card(
          child: Column(children: [
        _SelectedDrill(drillValue: _drillValue),
        buttons,
      ])),
    ]));
  }

  Widget _buildDrillSelector() {
    return _DrillSelector(staticDrills: staticDrills, drillValue: _drillValue);
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
    String title = 'Type: All';
    Text subtitle;
    DrillData drillData = widget.drillValue.value;
    if (drillData != null) {
      title = 'Type: ${drillData.type}';
      subtitle = Text(widget.drillValue.value.name);
    }
    return ListTile(title: Text(title), subtitle: subtitle);
  }
}

class _TimeWindowSelector extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TimeWindowSelectorState();
}

class _TimeWindowSelectorState extends State<_TimeWindowSelector> {
  static const options = ['Daily', 'Weekly', 'Monthly'];
  String selected = options[0];

  @override
  Widget build(BuildContext context) {
    return _SelectionChip(
      label: selected,
      onPressed: _onTimeWindowPressed,
    );
  }

  void _onTimeWindowPressed() async {
    String chosen = await showModalBottomSheet(
        context: context, builder: _timeWindowChooser);
    if (chosen == null) {
      return;
    }
    setState(() {
      selected = chosen;
    });
  }

  Widget _timeWindowChooser(BuildContext context) {
    final List<Widget> tiles = [
      ListTile(title: Text('Time Window')),
    ];
    tiles.addAll(options.map((String option) {
      return RadioListTile<String>(
        title: Text(option),
        value: option,
        groupValue: selected,
        onChanged: _onChosen,
      );
    }));
    return ListView(children: tiles);
  }

  void _onChosen(String selected) {
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
    return _SelectionChip(
      label: 'Select Drill',
      onPressed: _onDrillSelectorPressed,
    );
  }

  void _onDrillSelectorPressed() async {
    DrillData chosen = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => DrillChooserScreen(
                staticDrills: widget.staticDrills,
                selected: selected,
                allowAll: true)));
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
        label: Container(
            width: 70, child: Text(label, overflow: TextOverflow.ellipsis)),
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
