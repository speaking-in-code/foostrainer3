// Keys used in the app, exposed for testing. Do not add flutter dependencies
// here, they break integration tests.

import 'package:flutter/material.dart';

// Don't add new keys here, add them directly in the widgets that use them
// instead. (The way it was done here is a relic from flutter_driver
class Keys {
  static const pauseKey = 'pauseKey';
  static const playKey = 'playKey';
  static const moreKey = Key('moreKey');
  static const versionKey = 'versionKey';

  // Practice Config Screen
  static const drillTimeSliderKey = 'drillTimeSliderKey';
  static const drillTimeTextKey = 'drillTimeTextKey';
  static const tempoHeaderKey = 'drillTempoHeaderKey';
  static const fastKey = 'drillTempoFast';
  static const slowKey = 'drillTempoSlow';
  static const randomKey = 'drillTempoRandom';
  static const audioKey = 'drillSignalAudio';
  static const audioAndFlashKey = 'drillSignalAudioAndFlash';
  static const signalHeaderKey = 'drillSignalHeaderKey';
  static const trackingHeaderKey = 'drillTrackingHeaderKey';
  static const trackingAccuracyOnKey = 'drillTrackingAccuracyOn';
  static const trackingAccuracyOffKey = 'drillTrackingAccuracyOff';

  // Progress screen
  static const drillSelectionKey = Key('drillSelectionKey');
  static const accuracyTabKey = 'accuracyTabKey';

  static const calendarDatePicker = Key('calendarDatePicker');
}
