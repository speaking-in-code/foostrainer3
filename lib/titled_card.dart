import 'package:flutter/material.dart';

class TitledCard extends StatelessWidget {
  static const _padding = 16.0;
  final String title;
  final Widget child;

  TitledCard({@required this.title, @required this.child})
      : assert(title != null),
        assert(child != null);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      children: [
        _titleWidget(context),
        Divider(indent: _padding, endIndent: _padding),
        child,
      ],
    ));
  }

  Widget _titleWidget(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(_padding),
        child: SizedBox(
            width: double.infinity,
            child: Text(title, style: Theme.of(context).textTheme.headline6)));
  }
}
