import 'dart:core';

import 'package:flutter/material.dart';
import 'daily_drills_screen.dart';

import 'keys.dart';
import 'log.dart';
import 'no_drills_widget.dart';
import 'results_db.dart';
import 'spinner.dart';
import 'static_drills.dart';

final _log = Log.get('recent_drills');

class MonthlyDrillsWidget extends StatefulWidget {
  final ResultsDatabase resultsDb;
  final StaticDrills staticDrills;

  MonthlyDrillsWidget({required this.resultsDb, required this.staticDrills});

  @override
  State<StatefulWidget> createState() {
    return _MonthlyDrillsWidgetState();
  }
}

class _MonthlyDrills {
  final AllDrillDateRange allTime;
  final Set<DateTime> days;
  final DateTime? monthMin;
  final DateTime? monthMax;

  _MonthlyDrills(this.allTime, this.days, this.monthMin, this.monthMax);
}

class _MonthlyDrillsWidgetState extends State<MonthlyDrillsWidget> {
  Future<_MonthlyDrills>? _drills;

  @override
  void initState() {
    super.initState();
    _drills = _loadDrills(range: null, month: null);
  }

  // Loads drills for a given month. If range or month is not specified, uses
  // most recent month.
  Future<_MonthlyDrills> _loadDrills(
      {AllDrillDateRange? range, DateTime? month}) async {
    _log.info('Loading drills for $range, $month');
    range ??= await widget.resultsDb.drillsDao.dateRange();
    _log.info('All time ${range!.earliest} to ${range.latest}');
    month ??= range.latest;
    if (month == null) {
      // No drills at all.
      return _MonthlyDrills(range, {}, null, null);
    }
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 1);
    _log.info('Month $monthStart to $monthEnd');
    final drills = await widget.resultsDb.summariesDao
        .loadDrillsByDate(widget.resultsDb, start: monthStart, end: monthEnd);
    final drillDays = Set<DateTime>();
    DateTime? min;
    DateTime? max;
    drills.forEach((drill) {
      final startTime = drill.drill.startTime;
      final day = DateTime(startTime.year, startTime.month, startTime.day);
      drillDays.add(day);
      if (min == null || day.isBefore(min!)) {
        min = day;
      }
      if (max == null || day.isAfter(max!)) {
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
      return Spinner();
    }
    final _MonthlyDrills drills = snapshot.data!;
    if (drills.allTime.latest == null) {
      return NoDrillsWidget(staticDrills: widget.staticDrills);
    }
    return CalendarDatePicker(
        key: Keys.calendarDatePicker,
        initialDate: drills.monthMax!,
        firstDate: drills.allTime.earliest!,
        lastDate: drills.allTime.latest!,
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
    DailyDrillsScreen.push(context, date);
  }
}
