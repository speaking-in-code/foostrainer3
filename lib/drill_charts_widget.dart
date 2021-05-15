import 'package:flutter/material.dart';

import 'drill_data.dart';
import 'results_db.dart';
import 'static_drills.dart';

class DrillChartsWidget extends StatefulWidget {
  final StaticDrills staticDrills;
  final ResultsDatabase resultsDb;
  final DrillData drillData;

  DrillChartsWidget({this.staticDrills, this.resultsDb, this.drillData});

  @override
  State<StatefulWidget> createState() => DrillChartsWidgetState();
}

class DrillChartsWidgetState extends State<DrillChartsWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
