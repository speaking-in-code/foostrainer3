// Copied from https://material.io/components/dialogs/flutter#simple-dialog.
import 'package:flutter/material.dart';

class SimpleDialogItem extends StatelessWidget {
  const SimpleDialogItem(
      {Key key,
      this.icon,
      this.color,
      this.text,
      this.onPressed,
      this.iconSize = 48})
      : super(key: key);

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline6;
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: color),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16.0),
            child: Text(text, style: textStyle),
          ),
        ],
      ),
    );
  }
}
