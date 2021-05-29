import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ft3/percent_formatter.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

import 'drill_data.dart';
import 'drill_description_tile.dart';
import 'duration_formatter.dart';
import 'log.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'results_screen.dart';
import 'static_drills.dart';

final _log = Log.get('drill_list_widget');

class DrillListWidget extends StatefulWidget {
  final ResultsDatabase resultsDb;
  final StaticDrills staticDrills;
  final String drillFullName;

  DrillListWidget(
      {Key key,
      @required this.resultsDb,
      @required this.staticDrills,
      this.drillFullName})
      : assert(resultsDb != null),
        super(key: key) {
    _log.info('Creating drill list widget for drill=$drillFullName');
  }

  @override
  State<StatefulWidget> createState() => DrillListWidgetState(drillFullName);
}

class DrillListWidgetState extends State<DrillListWidget> {
  static const _pageSize = 20;
  static final _dateFormat = DateFormat.yMd().add_jm();
  static const _rowSpace = SizedBox(height: 6);
  final String drillFullName;
  PagingController<int, DrillSummary> _controller;

  DrillListWidgetState(this.drillFullName) {
    _log.info('Creating new drill list widget state for drill $drillFullName');
  }
  @override
  void initState() {
    super.initState();
    _controller = PagingController(firstPageKey: 0);
    _controller.addPageRequestListener((pageKey) => _fetchPage(pageKey));
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller = null;
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final List<DrillSummary> drills = await widget.resultsDb.summariesDao
          .loadRecentDrills(widget.resultsDb,
              limit: _pageSize, offset: pageKey, fullName: drillFullName);
      if (_controller == null) {
        // Future completed late.
        return;
      }
      if (drills.length < _pageSize) {
        _controller.appendLastPage(drills);
      } else {
        final nextPageKey = pageKey + drills.length;
        _controller.appendPage(drills, nextPageKey);
      }
    } catch (error) {
      _log.info('Error loading drills: $error');
      _controller.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView.separated(
        pagingController: _controller,
        separatorBuilder: (context, index) => const Divider(),
        builderDelegate: PagedChildBuilderDelegate<DrillSummary>(
          itemBuilder: (context, summary, index) =>
              _summaryLine(context, summary),
        ));
  }

  Widget _summaryLine(BuildContext context, DrillSummary summary) {
    final drillData = widget.staticDrills.getDrill(summary.drill.drill);
    return Padding(
        padding: EdgeInsets.all(8),
        child: Row(children: [
          Expanded(child: _drillInfo(context, summary, drillData)),
          IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => _onPressed(context, summary, drillData)),
        ]));
  }

  Widget _drillInfo(
      BuildContext context, DrillSummary summary, DrillData drillData) {
    final date = _dateFormat.format(summary.drill.startTime);
    String repsText;
    if (summary.good == null) {
      repsText = 'Reps: ${summary.reps}';
    } else {
      repsText =
          'Reps: ${summary.good}/${summary.reps}    ${PercentFormatter.format(summary.good / summary.reps)}';
    }
    final duration =
        'Duration: ${DurationFormatter.format(summary.drill.elapsed)}';
    final baseStyle = Theme.of(context).textTheme.bodyText2;
    final shaded = baseStyle.copyWith(color: baseStyle.color.withOpacity(0.8));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$date    ${drillData.type}', style: shaded),
        _rowSpace,
        Text(drillData.name, style: baseStyle),
        _rowSpace,
        Text(repsText, style: baseStyle),
        _rowSpace,
        Text(duration, style: baseStyle),
      ],
    );
  }

  void _onPressed(
      BuildContext context, DrillSummary summary, DrillData drillData) {
    ResultsScreen.push(context, summary.drill.id, drillData);
  }
}