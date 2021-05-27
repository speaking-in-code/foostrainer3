import 'package:flutter/material.dart';

class SelectionChip extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  SelectionChip({this.label, this.onPressed});

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
