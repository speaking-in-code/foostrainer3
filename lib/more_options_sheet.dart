import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class MoreOptionsSheet extends StatelessWidget {
  final Key key;

  MoreOptionsSheet({this.key});

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
  _FeedbackWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text('Send Feedback'),
        onTap: () => BetterFeedback.of(context).show());
  }
}

class _AboutWidget extends StatefulWidget {
  _AboutWidget({Key key}) : super(key: key);

  _AboutWidgetState createState() => _AboutWidgetState();
}

class _AboutWidgetState extends State<_AboutWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
          return ListTile(title: Text(_getVersion(snapshot)));
        });
  }
}

String _getVersion(AsyncSnapshot<PackageInfo> packageInfo) {
  if (packageInfo.hasData) {
    return 'Version: ${packageInfo.data.version}+${packageInfo.data.buildNumber}';
  }
  if (packageInfo.hasError) {
    return 'Version: Error. ${packageInfo.error}';
  }
  return 'Version: <loading>';
}
