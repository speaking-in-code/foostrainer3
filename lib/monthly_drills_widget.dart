import 'dart:core';

import 'package:flutter/material.dart';

import 'log.dart';
import 'results_db.dart';

final _log = Log.get('recent_drills');

class MonthlyDrillsWidget extends StatefulWidget {
  final ResultsDatabase resultsDb;

  MonthlyDrillsWidget(this.resultsDb);

  @override
  State<StatefulWidget> createState() {
    return _MonthlyDrillsWidgetState();
  }
}

class _MonthlyDrills {
  final AllDrillDateRange allTime;
  final Set<DateTime> days;
  final DateTime monthMin;
  final DateTime monthMax;

  _MonthlyDrills(this.allTime, this.days, this.monthMin, this.monthMax);
}

class _MonthlyDrillsWidgetState extends State<MonthlyDrillsWidget> {
  Future<_MonthlyDrills> _drills;

  @override
  void initState() {
    super.initState();
    _drills = _loadDrills(range: null, month: null);
  }

  // Loads drills for a given month. If range or month is not specified, uses
  // most recent month.
  Future<_MonthlyDrills> _loadDrills(
      {AllDrillDateRange range, DateTime month}) async {
    _log.info('Loading drills for $range, $month');
    range ??= await widget.resultsDb.drillsDao.dateRange();
    _log.info('All time ${range.earliest} to ${range.latest}');
    month ??= range.latest;
    if (month == null) {
      // No drills at all.
      return _MonthlyDrills(range, {}, null, null);
    }
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    _log.info('Month $monthStart to $monthEnd');
    final drills = await widget.resultsDb.summariesDao
        .loadDrillsByDate(widget.resultsDb, monthStart, monthEnd);
    final drillDays = Set<DateTime>();
    DateTime min;
    DateTime max;
    drills.forEach((drill) {
      final startTime = drill.drill.startTime;
      final day = DateTime(startTime.year, startTime.month, startTime.day);
      drillDays.add(day);
      if (min == null || day.isBefore(min)) {
        min = day;
      }
      if (max == null || day.isAfter(max)) {
        max = day;
      }
    });
    return _MonthlyDrills(range, drillDays, min, max);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: _drills, builder: _buildCalendar);
  }

  Widget _buildCalendar(
      BuildContext context, AsyncSnapshot<_MonthlyDrills> snapshot) {
    if (snapshot.hasError) {
      return Text('${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return Center(child: CircularProgressIndicator());
    }
    if (snapshot.data.allTime.latest == null) {
      // TODO(brian): make this a tap target to go the practice screen.
      return Center(child: Text('No drills. Go practice!'));
    }
    final _MonthlyDrills drills = snapshot.data;
    return CalendarDatePicker(
        initialDate: drills.monthMax,
        firstDate: drills.allTime.earliest,
        lastDate: drills.allTime.latest,
        onDisplayedMonthChanged: (DateTime month) =>
            _onDisplayedMonthChanged(drills, month),
        onDateChanged: _onDateChanged,
        selectableDayPredicate: (DateTime day) => drills.days.contains(day));
  }

  void _onDisplayedMonthChanged(_MonthlyDrills drills, DateTime month) {
    _log.info('New display month: $month');
    setState(() {
      _drills = _loadDrills(range: drills.allTime, month: month);
    });
  }

  void _onDateChanged(DateTime date) {
    // TODO(brian): navigate to date view for this.
    // Also add clickers to the drill selection screen to view drill history.
    _log.info('Select is $date');
  }
}
