import 'package:flutter/material.dart';
import 'package:ft3/percent_fomatter.dart';
import 'package:ft3/duration_formatter.dart';
import 'package:ft3/results_db.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

import 'results_entities.dart';

class RecentDrills extends StatefulWidget {
  final ResultsDatabase resultsDb;

  RecentDrills(this.resultsDb);

  @override
  State<StatefulWidget> createState() {
    return _RecentDrillsState();
  }
}

class _RecentDrillsState extends State<RecentDrills> {
  static const _pageSize = 20;
  final PagingController<int, WeeklyDrillSummary> _controller =
      PagingController(firstPageKey: 0);
  _RecentDrillsState();

  @override
  void initState() {
    _controller.addPageRequestListener((pageKey) => _fetchPage(pageKey));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final List<WeeklyDrillSummary> drills =
          await widget.resultsDb.summariesDao.loadWeeklyDrills(
              drill: null, action: null, numWeeks: _pageSize, offset: pageKey);
      if (drills.length < _pageSize) {
        _controller.appendLastPage(drills);
      } else {
        final nextPageKey = pageKey + drills.length;
        _controller.appendPage(drills, nextPageKey);
      }
    } catch (error) {
      _controller.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView(
        pagingController: _controller,
        builderDelegate: PagedChildBuilderDelegate<WeeklyDrillSummary>(
            itemBuilder: (context, summary, index) => _summaryLine(summary)));
    // separatorBuilder: (context, index) => const Divider());
  }

  Widget _summaryLine(WeeklyDrillSummary summary) {
    final start = DateFormat.yMMMd().format(summary.startDay);
    final end = DateFormat.yMMMd().format(summary.endDay);
    String subtitle;
    if (summary.accuracy != null) {
      subtitle =
          'Time: ${DurationFormatter.format(Duration(seconds: summary.elapsedSeconds))}\n' +
              'Reps: ${summary.reps} (${PercentFormatter.format(summary.accuracy)})';
    } else {
      subtitle =
          'Time: ${DurationFormatter.format(Duration(seconds: summary.elapsedSeconds))}\n' +
              'Reps: ${summary.reps}';
    }
    // TODO: tap target leading to detailed breakdown
    return Card(
      child: ListTile(
          title: Text('$start - $end'),
          subtitle: Text('$subtitle'),
          isThreeLine: true),
    );
  }
}
