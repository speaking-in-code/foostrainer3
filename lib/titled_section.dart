import 'package:flutter/material.dart';

class TitledSection extends StatelessWidget {
  static const _padding = 16.0;
  final String title;
  final Widget child;

  TitledSection({@required this.title, @required this.child})
      : assert(title != null),
        assert(child != null);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _titleWidget(context),
        child,
      ],
    );
  }

  Widget _titleWidget(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: _padding),
        child: SizedBox(
            width: double.infinity,
            child: Text(title, style: Theme.of(context).textTheme.subtitle2)));
  }
}
