import 'package:flutter/material.dart';
import 'dart:math';

import 'log.dart';
import 'simple_dialog_item.dart';
import 'tracking_info.dart';

final _log = Log.get('tracking_dialog');

typedef TrackingDialogCallback = void Function(TrackingResult);

class TrackingDialog extends StatelessWidget {
  static const _iconSize = 72.0;
  static const _space = SizedBox(height: 20, width: 20);

  final TrackingDialogCallback callback;

  const TrackingDialog({Key? key, required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Enter Result'),
      children: [_items(context)],
    );
  }

  Widget _items(BuildContext context) {
    final screen = MediaQuery.of(context);
    final options = [
      SimpleDialogItem(
        onPressed: () => callback(TrackingResult.GOOD),
        text: 'Good',
        icon: Icons.thumb_up,
        iconSize: _iconSize,
        color: Theme.of(context).colorScheme.secondary,
      ),
      _space,
      SimpleDialogItem(
        onPressed: () => callback(TrackingResult.MISSED),
        text: 'Missed',
        icon: Icons.thumb_down,
        iconSize: _iconSize,
        color: Theme.of(context).colorScheme.error,
      ),
      _space,
      SimpleDialogItem(
        onPressed: () => callback(TrackingResult.SKIP),
        text: 'Skip',
        icon: Icons.double_arrow,
        iconSize: _iconSize,
        color: Theme.of(context).colorScheme.surface,
      ),
    ];
    if (screen.orientation == Orientation.portrait) {
      return Column(children: options);
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: options);
  }
}
