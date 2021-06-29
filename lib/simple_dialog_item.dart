// Copied from https://material.io/components/dialogs/flutter#simple-dialog.
import 'package:flutter/material.dart';

class SimpleDialogItem extends StatelessWidget {
  static const _insets = const EdgeInsetsDirectional.only(start: 16.0);

  const SimpleDialogItem(
      {Key? key,
      required this.icon,
      required this.color,
      required this.text,
      this.onPressed,
      this.iconSize = 48})
      : super(key: key);

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback? onPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline6!;
    // For portrait mode, text goes next to icon.
    // For landsacpe, text goes under icon.
    final child = MediaQuery.of(context).orientation == Orientation.portrait
        ? _buildRow(textStyle)
        : _buildColumn(textStyle);
    return SimpleDialogOption(onPressed: onPressed, child: child);
  }

  Widget _buildRow(TextStyle style) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: iconSize, color: color),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16.0),
          child: Text(text, style: style),
        ),
      ],
    );
  }

  Widget _buildColumn(TextStyle style) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: iconSize, color: color),
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 16.0),
          child: Text(text, style: style),
        ),
      ],
    );
  }
}
