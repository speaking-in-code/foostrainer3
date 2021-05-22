import 'package:flutter/material.dart';

class TitledCard extends StatelessWidget {
  static const _padding = 16.0;
  final Widget title;
  final Widget child;

  TitledCard({@required this.title, @required this.child})
      : assert(title != null),
        assert(child != null);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      children: [
        Padding(padding: EdgeInsets.all(_padding), child: title),
        Divider(indent: _padding, endIndent: _padding),
        child,
      ],
    ));
  }
}
