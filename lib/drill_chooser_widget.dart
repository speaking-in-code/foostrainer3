import 'package:flutter/material.dart';

import 'drill_data.dart';
import 'static_drills.dart';

typedef void OnDrillChosen(DrillData? selected);

class DrillChooserWidget extends StatefulWidget {
  final StaticDrills staticDrills;
  final OnDrillChosen onDrillChosen;
  final DrillData? selected;
  final bool allowAll;

  /// Creates a drill chooser widget. onSelected is notified when the user has
  /// made a selection.
  DrillChooserWidget(
      {required this.staticDrills,
      required this.onDrillChosen,
      this.selected,
      this.allowAll = false});

  @override
  State<StatefulWidget> createState() => _DrillChooserWidgetState();
}

class _DrillChooserWidgetState extends State<DrillChooserWidget> {
  static const _allType = 'all';
  late List<String> choices;
  String? selectedType;
  TextStyle? typeStyle;
  TextStyle? drillStyle;

  @override
  void initState() {
    super.initState();
    choices = [];
    if (widget.allowAll) {
      choices.add(_allType);
    }
    choices.addAll(widget.staticDrills.types);
    selectedType = widget.selected?.type;
    if (selectedType == null && widget.allowAll) {
      selectedType = _allType;
    }
  }

  @override
  Widget build(BuildContext context) {
    typeStyle = Theme.of(context).textTheme.bodyText1;
    typeStyle = typeStyle!.copyWith(color: typeStyle!.color!.withOpacity(0.8));
    drillStyle = Theme.of(context).textTheme.bodyText1;
    final children =
        choices.map((drillType) => _buildPanel(drillType)).toList();
    return SingleChildScrollView(
      child: Container(
          child: ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.zero,
              expansionCallback: _expansionCallback,
              children: children)),
    );
  }

  void _expansionCallback(int index, bool currentlyExpanded) {
    setState(() {
      if (currentlyExpanded) {
        selectedType = choices[index];
      } else {
        selectedType = null;
      }
    });
  }

  ExpansionPanel _buildPanel(String drillType) {
    if (drillType == _allType) {
      return ExpansionPanel(
        headerBuilder: (context, isExpanded) =>
            _buildHeader(context, isExpanded, drillType),
        body: _buildAllTileBody(),
        isExpanded: selectedType == drillType,
        canTapOnHeader: true,
      );
    }
    final drillDatas = widget.staticDrills.getDrills(drillType);
    return ExpansionPanel(
      headerBuilder: (context, isExpanded) =>
          _buildHeader(context, isExpanded, drillType),
      body: _buildBody(drillDatas),
      isExpanded: selectedType == drillType,
      canTapOnHeader: true,
    );
  }

  Widget _buildHeader(BuildContext context, bool isExpanded, String drillType) {
    if (drillType == _allType) {
      drillType = 'All Drills';
    }
    return ListTile(title: Text(drillType, style: typeStyle));
  }

  Widget _buildAllTileBody() {
    return ListTile(
      title: Text('Show All Drills', style: drillStyle),
      trailing: Icon(Icons.arrow_right, color: drillStyle!.color),
      onTap: () => widget.onDrillChosen(null),
    );
  }

  Widget _buildBody(List<DrillData> drillDatas) {
    return ListView.separated(
      shrinkWrap: true,
      primary: false,
      itemCount: drillDatas.length,
      itemBuilder: (context, itemIndex) => _buildDrill(drillDatas[itemIndex]),
      separatorBuilder: (context, itemIndex) => const Divider(),
    );
  }

  Widget _buildDrill(DrillData drillData) {
    return ListTile(
        key: Key(drillData.fullName),
        title: Text(drillData.name, style: drillStyle),
        trailing: Icon(Icons.arrow_right, color: drillStyle!.color),
        onTap: () {
          widget.onDrillChosen(drillData);
        });
  }
}
