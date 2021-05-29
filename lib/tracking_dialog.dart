import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ft3/tracking_info.dart';

import 'simple_dialog_item.dart';

typedef TrackingDialogCallback = void Function(TrackingResult);

class TrackingDialog extends StatelessWidget {
  static const iconSize = 72.0;
  final TrackingDialogCallback callback;

  const TrackingDialog({Key key, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Enter Result'),
      children: _items(context),
    );
  }

  List<Widget> _items(BuildContext context) {
    return [
      SimpleDialogItem(
        onPressed: () => callback(TrackingResult.GOOD),
        text: 'Good',
        icon: Icons.thumb_up,
        iconSize: iconSize,
        color: Theme.of(context).accentColor,
      ),
      SimpleDialogItem(
        onPressed: () => callback(TrackingResult.MISSED),
        text: 'Missed',
        icon: Icons.thumb_down,
        iconSize: iconSize,
        color: Theme.of(context).unselectedWidgetColor,
      ),
      SimpleDialogItem(
        onPressed: () => callback(TrackingResult.SKIP),
        text: 'Skip',
        icon: Icons.double_arrow,
        iconSize: iconSize,
        color: Theme.of(context).primaryColor,
      ),
    ];
  }
}
