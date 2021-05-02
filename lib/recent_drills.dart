import 'dart:core';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'date_formatter.dart';
import 'duration_formatter.dart';
import 'percent_fomatter.dart';
import 'results_db.dart';
import 'results_entities.dart';

// TODO for this screen
// - add a tap target to display a single drill.
// - compress the UI. Maybe drop accuracy
// - maybe replace this entire thing with a calendar with clickable days
// - maybe replace this entire thing with a graph
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
    final paged = PagedSliverList<int, WeeklyDrillSummary>(
      pagingController: _controller,
      builderDelegate: PagedChildBuilderDelegate<WeeklyDrillSummary>(
          itemBuilder: (context, summary, index) =>
              _ExpandableSummary(widget.resultsDb, summary, index)),
    );
    return Column(children: [
      _header(context),
      Expanded(child: CustomScrollView(slivers: [paged]))
    ]);
  }

  Widget _header(BuildContext context) {
    final theme = ExpandableThemeData.withDefaults(
        ExpandableThemeData(
          tapHeaderToExpand: false,
          hasIcon: false,
        ),
        context);
    return ExpandablePanel(
      theme: theme,
      header: _RecentRow('Week', 'Time', 'Reps', 'Accuracy'),
    );
  }
}

class _ExpandableSummary extends StatelessWidget {
  final ResultsDatabase resultsDb;
  final WeeklyDrillSummary summary;
  final int index;

  _ExpandableSummary(this.resultsDb, this.summary, this.index);

  @override
  Widget build(BuildContext context) {
    final start = DateFormatter.format(summary.startDay);
    final end = DateFormatter.format(summary.endDay);
    final accuracy = summary.accuracy != null
        ? PercentFormatter.format(summary.accuracy)
        : '-';
    Color color = Theme.of(context).primaryColor;
    if (index.isOdd) {
      color = color.withOpacity(0.1);
    }
    final collapsed = _RecentRow(
        '$start\n$end',
        DurationFormatter.format(Duration(seconds: summary.elapsedSeconds)),
        '${summary.reps}',
        accuracy);
    return Container(
      color: color,
      child: ExpandablePanel(
        header: collapsed,
        expanded: _ExpandedDrills(resultsDb, summary),
        theme: _theme(context),
      ),
    );
  }

  ExpandableThemeData _theme(BuildContext context) {
    return ExpandableThemeData.withDefaults(
        ExpandableThemeData(
          tapHeaderToExpand: true,
          hasIcon: false,
        ),
        context);
  }
}

class _ExpandedDrills extends StatefulWidget {
  final ResultsDatabase resultsDb;
  final WeeklyDrillSummary summary;

  _ExpandedDrills(this.resultsDb, this.summary);

  @override
  State<_ExpandedDrills> createState() {
    return _ExpandedDrillsState();
  }
}

class _ExpandedDrillsState extends State<_ExpandedDrills> {
  Future<List<DrillSummary>> _drills;

  @override
  void initState() {
    _drills = widget.resultsDb.summariesDao.loadDrillsByDate(
        widget.resultsDb, widget.summary.startDay, widget.summary.endDay);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DrillSummary>>(
      future: _drills,
      builder:
          (BuildContext context, AsyncSnapshot<List<DrillSummary>> snapshot) =>
              _buildCard(context, snapshot),
    );
  }

  Widget _buildCard(
      BuildContext context, AsyncSnapshot<List<DrillSummary>> snapshot) {
    return Card(child: _build(context, snapshot));
  }

  Widget _build(
      BuildContext context, AsyncSnapshot<List<DrillSummary>> snapshot) {
    if (snapshot.hasError) {
      return ListTile(
          title: Text('${snapshot.error}'), leading: Icon(Icons.error));
    }
    if (!snapshot.hasData) {
      return CircularProgressIndicator(semanticsLabel: 'Loading Drills');
    }
    List<Widget> rows = [];
    for (int i = 0; i < snapshot.data.length; ++i) {
      rows.add(_buildDrill(context, snapshot.data[i]));
      if (i < snapshot.data.length - 1) {
        rows.add(const Divider());
      }
    }
    return Column(children: rows);
  }

  Widget _buildDrill(BuildContext context, DrillSummary drill) {
    return ListTile(
      dense: true,
      title: _drillHeader(drill),
      subtitle: _drillDetails(drill),
    );
  }

  Widget _drillHeader(DrillSummary drill) {
    final when = DateFormatter.format(drill.drill.startTime);
    return Text('$when ${drill.drill.drill}');
  }

  Widget _drillDetails(DrillSummary drill) {
    if (drill.accuracy == null) {
      return Text(
          'Reps: ${drill.reps} Time: ${DurationFormatter.format(drill.drill.elapsed)}');
    }
    return Text(
        'Reps: ${drill.reps} (${PercentFormatter.format(drill.accuracy)}) Time: ${DurationFormatter.format(drill.drill.elapsed)}');
  }
}

class _RecentRow extends StatelessWidget {
  final String dates;
  final String duration;
  final String reps;
  final String accuracy;

  _RecentRow(this.dates, this.duration, this.reps, this.accuracy);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        dense: true,
        subtitle: Row(
          children: [
            Expanded(flex: 3, child: Text(dates, textAlign: TextAlign.center)),
            Expanded(
                flex: 2, child: Text(duration, textAlign: TextAlign.center)),
            Expanded(flex: 2, child: Text(reps, textAlign: TextAlign.center)),
            Expanded(
                flex: 2, child: Text(accuracy, textAlign: TextAlign.center)),
          ],
        ));
  }
}
