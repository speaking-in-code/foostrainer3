import 'package:flutter/material.dart';
import 'package:ft3/drill_types_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'duration_formatter.dart';
import 'log.dart';
import 'my_app_bar.dart';
import 'results_info.dart';

final _log = Log.get('results_screen');

class ResultsScreen extends StatefulWidget {
  static const routeName = '/results';
  ResultsScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Future<SharedPreferences> _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _prefs,
      builder: (BuildContext context, AsyncSnapshot<SharedPreferences> prefs) {
        _log.info('Rendering, ${prefs.connectionState}');
        return Scaffold(
          appBar: MyAppBar(title: 'Drill Complete').build(context),
          body: (prefs.hasData ? _ResultsWidget(prefs: prefs.data) : null),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).buttonColor,
            onPressed: () => Navigator.pushReplacementNamed(
                context, DrillTypesScreen.routeName),
            child: Icon(Icons.done),
          ),
        );
      },
    );
  }
}

class _ResultsWidget extends StatelessWidget {
  static const _noData = '--';
  static final _pctFormatter = NumberFormat.percentPattern()
    ..maximumFractionDigits = 0;
  final ResultsInfo results;

  _ResultsWidget({Key key, SharedPreferences prefs})
      : results = _parse(prefs),
        super(key: key);

  static ResultsInfo _parse(SharedPreferences prefs) {
    final data = prefs.getString(ResultsInfo.prefsKey);
    _log.info('Read $data');
    return ResultsInfo.decode(data);
  }

  @override
  Widget build(BuildContext context) {
    final dataStyle = Theme.of(context).textTheme.headline5;
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Row(children: [
        Expanded(
          child: Text(results.drill,
              textAlign: TextAlign.center, style: dataStyle),
        ),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _firstColumn(dataStyle),
        _secondColumn(dataStyle),
      ]),
    ]);
  }

  Widget _padBelow(Text text) {
    return Padding(padding: EdgeInsets.only(bottom: 16), child: text);
  }

  Widget _firstColumn(TextStyle dataStyle) {
    final successText = results.good ?? _noData;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Reps'),
        _padBelow(Text('${results.reps}', style: dataStyle)),
        Text('Success'),
        Text('$successText', style: dataStyle),
      ],
    );
  }

  Widget _secondColumn(TextStyle dataStyle) {
    final durationText =
        DurationFormatter.format(Duration(seconds: results.elapsedSeconds));
    final accuracyText = (results.good != null && results.reps > 0)
        ? _pctFormatter.format(results.good / results.reps)
        : _noData;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Duration'),
        _padBelow(Text('$durationText', style: dataStyle)),
        Text('Accuracy'),
        Text('$accuracyText', style: dataStyle),
      ],
    );
  }
}
