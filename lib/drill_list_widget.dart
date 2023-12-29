import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'drill_data.dart';
import 'date_formatter.dart';
import 'duration_formatter.dart';
import 'log.dart';
import 'percent_formatter.dart';
import 'results_db.dart';
import 'results_entities.dart';
import 'results_screen.dart';
import 'static_drills.dart';

final _log = Log.get('drill_list_widget');

class DrillListWidget extends StatefulWidget {
  final ResultsDatabase resultsDb;
  final StaticDrills staticDrills;
  final String? drillFullName;
  //final DateTime date;
  final DateTime? startDate;
  final DateTime? endDate;

  DrillListWidget(
      {Key? key,
      required this.resultsDb,
      required this.staticDrills,
      this.drillFullName,
      this.startDate,
      this.endDate})
      : assert(resultsDb != null),
        super(key: key) {
    _log.info(
        'Creating drill list widget for drill=$drillFullName start=$startDate end=$endDate');
  }

  @override
  State<StatefulWidget> createState() => DrillListWidgetState(drillFullName);
}

class DrillListWidgetState extends State<DrillListWidget> {
  static const _pageSize = 20;
  static const _rowSpace = SizedBox(height: 6);
  final String? drillFullName;
  PagingController<int, DrillSummary>? _controller;

  DrillListWidgetState(this.drillFullName) {
    _log.info('Creating new drill list widget state for drill $drillFullName');
  }
  @override
  void initState() {
    super.initState();
    _controller = PagingController(firstPageKey: 0);
    _controller!.addPageRequestListener((pageKey) => _fetchPage(pageKey));
  }

  @override
  void dispose() {
    _controller!.dispose();
    _controller = null;
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final List<DrillSummary> drills = await widget.resultsDb.summariesDao
          .loadDrillsByDate(widget.resultsDb,
              limit: _pageSize,
              offset: pageKey,
              fullName: drillFullName,
              start: widget.startDate,
              end: widget.endDate);
      if (_controller == null) {
        // Future completed late.
        return;
      }
      if (drills.length < _pageSize) {
        _controller!.appendLastPage(drills);
      } else {
        final nextPageKey = pageKey + drills.length;
        _controller!.appendPage(drills, nextPageKey);
      }
    } catch (error) {
      _log.info('Error loading drills: $error');
      _controller!.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView.separated(
        pagingController: _controller!,
        separatorBuilder: (context, index) => const Divider(),
        builderDelegate: PagedChildBuilderDelegate<DrillSummary>(
          itemBuilder: (context, summary, index) =>
              _summaryLine(context, summary),
        ));
  }

  Widget _summaryLine(BuildContext context, DrillSummary summary) {
    final drillData = widget.staticDrills.getDrill(summary.drill.drill)!;
    return Padding(
        padding: EdgeInsets.all(8),
        child: InkWell(
            onTap: () => _onPressed(context, summary, drillData),
            child: Row(children: [
              Expanded(child: _drillInfo(context, summary, drillData)),
            ])));
  }

  // TODO(brian): see how this looks on smaller screen, maybe merge reps
  // and accuracy into a single line, or maybe make it a single column layout
  // instead.
  Widget _drillInfo(
      BuildContext context, DrillSummary summary, DrillData drillData) {
    final date = DateFormatter.formatDayTime(summary.drill.startTime);
    String repsText;
    if (summary.good == null) {
      repsText = 'Reps: ${summary.reps}';
    } else {
      repsText = 'Reps: ${summary.good}/${summary.reps}';
    }
    final duration =
        'Duration: ${DurationFormatter.format(summary.drill.elapsed)}';
    final baseStyle = Theme.of(context).textTheme.bodyText2!;
    final shaded = baseStyle.copyWith(color: baseStyle.color!.withOpacity(0.8));
    final children = [
      _leftAndRight(
          Text('${drillData.type}', style: shaded), Text(date, style: shaded)),
      _rowSpace,
      Text(drillData.name, style: baseStyle, textAlign: TextAlign.center),
      _rowSpace,
      _leftAndRight(
          Text(repsText, style: baseStyle), Text(duration, style: baseStyle)),
    ];
    if (summary.good != null && summary.reps > 0) {
      children.addAll([
        _rowSpace,
        Text(
            'Accuracy: ${PercentFormatter.format(summary.good! / summary.reps)}',
            style: baseStyle),
      ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _leftAndRight(Widget left, Widget right) {
    return Row(children: [left, Spacer(), right]);
  }

  void _onPressed(
      BuildContext context, DrillSummary summary, DrillData drillData) {
    ResultsScreen.push(context, summary.drill.id!, drillData);
  }
}
