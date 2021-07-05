import 'package:flutter/material.dart';

import 'app_rater.dart';
import 'drill_data.dart';
import 'keys.dart';
import 'more_options_sheet.dart';

class MyAppBar {
  static final Key moreKey = Key(Keys.moreKey);
  final Key? key;
  final String? title;
  final DrillData? drillData;
  final Widget? titleWidget;
  final AppRater appRater;
  final bool includeMoreAction;
  final List<IconButton> actions;

  factory MyAppBar(
      {Key? key,
      required String title,
      required AppRater appRater,
      bool includeMoreAction = true,
      List<IconButton> actions = const []}) {
    return MyAppBar._internal(
        key: key,
        title: title,
        appRater: appRater,
        includeMoreAction: includeMoreAction,
        actions: actions);
  }

  factory MyAppBar.drillTitle(
      {Key? key,
      required DrillData? drillData,
      required AppRater appRater,
      bool includeMoreAction = true,
      List<IconButton> actions = const []}) {
    return MyAppBar._internal(
        key: key,
        drillData: drillData,
        appRater: appRater,
        includeMoreAction: includeMoreAction,
        actions: actions);
  }

  factory MyAppBar.titleWidget(
      {Key? key,
      required Widget titleWidget,
      required AppRater appRater,
      bool includeMoreAction = true,
      List<IconButton> actions = const []}) {
    return MyAppBar._internal(
        key: key,
        titleWidget: titleWidget,
        appRater: appRater,
        includeMoreAction: includeMoreAction,
        actions: actions);
  }

  MyAppBar._internal(
      {this.key,
      this.title,
      required this.appRater,
      this.drillData,
      this.titleWidget,
      this.includeMoreAction = true,
      this.actions = const []})
      : assert(title != null || drillData != null || titleWidget != null);

  PreferredSizeWidget build(BuildContext context) {
    return _appBar(context);
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    Widget? titleWidget;
    if (this.titleWidget != null) {
      titleWidget = this.titleWidget;
    } else if (title != null) {
      titleWidget = Text(title!);
    } else {
      titleWidget = Column(
        children: [
          Text(drillData!.type, style: Theme.of(context).textTheme.subtitle1),
          Text(drillData!.name, style: Theme.of(context).textTheme.bodyText2),
        ],
      );
    }
    return AppBar(
        key: key,
        centerTitle: true,
        title: titleWidget,
        actions: _makeActions(context));
  }

  List<IconButton> _makeActions(BuildContext context) {
    if (!includeMoreAction) {
      return actions;
    }
    return actions +
        [
          IconButton(
            icon: const Icon(Icons.more_vert),
            key: moreKey,
            tooltip: 'More Options',
            onPressed: () => _onMoreOptions(context),
          ),
        ];
  }

  Future<void> _onMoreOptions(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) =>
            MoreOptionsSheet(appRater: appRater));
  }
}
