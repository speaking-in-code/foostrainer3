import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart' as treeview;

import 'drill_data.dart';
import 'static_drills.dart';

typedef void OnDrillChosen(DrillData selected);

class DrillChooserWidget extends StatefulWidget {
  final StaticDrills staticDrills;
  final OnDrillChosen onDrillChosen;
  final DrillData selected;
  final bool allowAll;
  final bool shrinkWrap;
  final bool primaryScroll;

  /// Creates a drill chooser widget. onSelected is notified when the user has
  /// made a selection.
  DrillChooserWidget(
      {@required this.staticDrills,
      @required this.onDrillChosen,
      this.selected,
      this.allowAll = false,
      this.shrinkWrap = false,
      this.primaryScroll = false})
      : assert(staticDrills != null);

  @override
  State<StatefulWidget> createState() => _DrillChooserWidgetState();
}

class _DrillChooserWidgetState extends State<DrillChooserWidget> {
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
    setState(() {
      _controller = _controller.copyWith(selectedKey: key);
    });
    widget.onDrillChosen(node.data);
  }

  @override
  Widget build(BuildContext context) {
    return treeview.TreeView(
      controller: _controller,
      shrinkWrap: widget.shrinkWrap,
      primary: widget.primaryScroll,
      onExpansionChanged: _onExpansionChanged,
      onNodeTap: _onNodeTap,
      theme: _treeViewTheme,
    );
  }
}
