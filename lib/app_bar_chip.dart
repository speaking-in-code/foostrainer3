import 'package:flutter/material.dart';

class AppBarChip extends StatelessWidget {
  final Widget label;
  final VoidCallback onPressed;

  AppBarChip({this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return RawChip(
        label: label,
        onSelected: (_) => this.onPressed(),
        selected: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        onDeleted: this.onPressed,
        deleteIcon: Icon(Icons.arrow_drop_down));
  }
}
