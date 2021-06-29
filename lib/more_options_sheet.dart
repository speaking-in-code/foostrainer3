import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'debug_screen.dart';
import 'feedback_sender.dart';
import 'keys.dart';

class MoreOptionsSheet extends StatelessWidget {
  static final Key versionKey = Key(Keys.versionKey);
  final Key? key;

  MoreOptionsSheet({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _FeedbackWidget(),
        _AboutWidget(),
      ],
    ));
  }
}

class _FeedbackWidget extends StatelessWidget {
  final _feedbackSender = FeedbackSender();
  _FeedbackWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Send Feedback'),
      onTap: () => _feedbackSender.send(),
    );
  }
}

class _AboutWidget extends StatefulWidget {
  _AboutWidget({Key? key}) : super(key: key);

  _AboutWidgetState createState() => _AboutWidgetState();
}

class _AboutWidgetState extends State<_AboutWidget> {
  static const kMaxClickDelay = Duration(seconds: 1);
  static const kClicksToEnter = 3;

  DateTime? lastClick;
  int numClicks = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
          return ListTile(
              title:
                  Text(_getVersion(snapshot), key: MoreOptionsSheet.versionKey),
              onTap: _onTap);
        });
  }

  // Enter debug screen if there are three clicks on the version info tag.
  void _onTap() {
    final now = DateTime.now();
    if (lastClick == null || now.difference(lastClick!) > kMaxClickDelay) {
      numClicks = 1;
    } else {
      ++numClicks;
    }
    lastClick = now;
    if (numClicks >= kClicksToEnter) {
      numClicks = 0;
      Navigator.pushNamed(context, DebugScreen.routeName);
    }
  }
}

String _getVersion(AsyncSnapshot<PackageInfo> packageInfo) {
  if (packageInfo.hasData) {
    return 'Version: ${packageInfo.data!.version}+${packageInfo.data!.buildNumber}';
  }
  if (packageInfo.hasError) {
    return 'Version: Error. ${packageInfo.error}';
  }
  return 'Version: <loading>';
}
