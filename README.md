# FoosTrainer v3

FoosTrainer v3 is a redesign of the original FoosTrainer app for Android.

The goals for the redesign:

* Cleaner, more modern mobile UI.
* Fix bugs with delayed timers on some devices.
* Support custom drills and timings.
* Prepare for an eventual iOS port.

## Development Plan

### M1: beta release

Needed features

* Shooting drills for pull and rollover.
* Background execution that works.
** Using https://pub.dev/packages/audio_service seems good.
** Still need to get 3-way communication between app UI, notification UI, and background task.
* Nice UI.
* Support for Android v23+.

### M2: public release

* Fix bugs reported in beta.
* (internals) Crash reporting & analytics.
* Replace the existing foostrainer app in the Android store.

### M3: custom drills

* Allow creation of new drills.
* Allow save and restoration of drills across devices.
