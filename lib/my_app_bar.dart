import 'package:flutter/material.dart';

import 'more_options_sheet.dart';

class MyAppBar {
  final Key key;
  final String title;

  const MyAppBar({this.key, this.title});

  AppBar build(BuildContext context) {
    return AppBar(key: key, title: Text(title), actions: <Widget>[
      IconButton(
        icon: const Icon(Icons.more_vert),
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
