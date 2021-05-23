import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart' as treeview;

import 'drill_data.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'static_drills.dart';

final _log = Log.get('drill_chooser_screen');

/// Let's the user choose a drill, or all drills.
/// This is intended to be shown with showDialog(), which returns the se
/// selected node as Future<DrillData>.
class DrillChooserScreen extends StatefulWidget {
  final StaticDrills staticDrills;
  final DrillData selected;
  final bool allowAll;

  DrillChooserScreen(
      {@required this.staticDrills, this.selected, this.allowAll = false})
      : assert(staticDrills != null);

  @override
  State<StatefulWidget> createState() => _DrillChooserScreenState();
}

class _DrillChooserScreenState extends State<DrillChooserScreen> {
  static const allKey = 'all';
  treeview.TreeViewController _controller;

  @override
  void initState() {
    super.initState();
    final List<treeview.Node<DrillData>> nodes = [];
    if (widget.allowAll) {
      nodes.add(treeview.Node<DrillData>(key: allKey, label: 'All'));
    }
    nodes.addAll(widget.staticDrills.types.map(_typeNode));
    _controller = treeview.TreeViewController(
        children: nodes, selectedKey: widget.selected?.fullName);
  }

  treeview.Node<DrillData> _typeNode(String type) {
    List<treeview.Node<DrillData>> drills =
        widget.staticDrills.getDrills(type).map(_drillNode).toList();
    bool expanded = false;
    if (type == widget.selected?.type) {
      expanded = true;
    }
    return treeview.Node(
        key: type, label: type, expanded: expanded, children: drills);
  }

  treeview.Node<DrillData> _drillNode(DrillData drill) {
    return treeview.Node(key: drill.fullName, label: drill.name, data: drill);
  }

  treeview.TreeViewTheme get _treeViewTheme {
    final theme = Theme.of(context);
    return treeview.TreeViewTheme(
      expanderTheme: treeview.ExpanderThemeData(
        color: theme.selectedRowColor,
      ),
      colorScheme: theme.colorScheme,
    );
  }

  void _onExpansionChanged(String key, bool expanded) {
    treeview.Node node = _controller.getNode(key);
    if (node == null) {
      return;
    }
    final updated =
        _controller.updateNode(key, node.copyWith(expanded: expanded));
    setState(() {
      _controller = _controller.copyWith(children: updated);
    });
  }

  void _onNodeTap(String key) {
    treeview.Node<DrillData> node = _controller.getNode(key);
    Navigator.pop(context, node.data);
  }

  @override
  Widget build(BuildContext context) {
    final treeView = treeview.TreeView(
        controller: _controller,
        shrinkWrap: false,
        onExpansionChanged: _onExpansionChanged,
        onNodeTap: _onNodeTap,
        theme: _treeViewTheme);
    return Scaffold(
      appBar: MyAppBar(title: 'Choose Drill').build(context),
      body: treeView,
    );
  }
}
