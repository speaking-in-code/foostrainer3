import 'package:flutter/material.dart';

class InsetDivider extends StatelessWidget {
  static const _inset = 16.0;
  final double? thickness;

  InsetDivider({this.thickness});

  @override
  Widget build(BuildContext context) {
    return Divider(indent: _inset, endIndent: _inset, thickness: thickness);
  }
}
