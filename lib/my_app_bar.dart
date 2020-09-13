import 'package:flutter/material.dart';

import 'keys.dart';
import 'more_options_sheet.dart';

class MyAppBar {
  static final Key moreKey = Key(Keys.moreKey);
  final Key key;
  final String title;

  const MyAppBar({this.key, this.title});

  AppBar build(BuildContext context) {
    return AppBar(key: key, title: Text(title), actions: <Widget>[
      IconButton(
        icon: const Icon(Icons.more_vert),
        key: moreKey,
        tooltip: 'More Options',
        onPressed: () => _onMoreOptions(context),
      ),
    ]);
  }

  Future<void> _onMoreOptions(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => MoreOptionsSheet());
  }
}
