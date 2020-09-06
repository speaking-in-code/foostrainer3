# FoosTrainer v3

FoosTrainer v3 is a redesign of the original FoosTrainer app for Android.

The goals for the redesign:

* Cleaner, more modern mobile UI.
* Fix bugs with delayed timers on some devices.
* Support custom drills and timings.
* Prepare for an eventual iOS port.

## Run Widget Tests

```
flutter test
```

## Run On-Device tests

Start a simulator, or attach a real device. Then run

```
flutter drive --target=test_driver/main.dart
```

For faster edit/test cycle, follow instructions from here:

https://medium.com/flutter-community/hot-reload-for-flutter-integration-tests-e0478b63bd54

In one window, start the app
```
flutter run --observatory-port 8888 --disable-service-auth-codes test_driver/main.dart
```

In another window, start the tests:
```
flutter drive --use-existing-app=http://127.0.0.1:8888/ --driver test_driver/main_test.dart
```

Press 'R' in the app window to hot restart the app. Press '?' for additional commands.

Note that the well-documented version of the 'flutter drive' command  
does not work. For reasons I don't understand, the app fails to connect  
to the background audio service and so drills don't execute.

## Release Build

This will build and install the app to a locally connected device.

```
bash tools/prod-build.sh
```

## Production Release

Edit pubspec.yaml and bump the version key (e.g. 2.0.0+10 => 2.0.0+11).

```
bash tools/prod-build.sh
```

Upload the new version to the
[beta track in the play store](https://play.google.com/apps/publish/?account=8099263646066676021#ManageReleasesPlace:p=net.speakingincode.foostrainer&appid=4972318416623669354).


## Update Screenshots after UI Change

```
pub global activate screenshots
~/.pub-cache/bin/screenshots
```

## Development Plan

### M1: beta release (done)

Needed features

* Shooting drills for pull and rollover.
* Background execution that works.
* Nice UI.
* Support for Android v23+.

### M2: public release (done)

* Fix bugs reported in beta.
* (internals) Crash reporting & analytics.
* Replace the existing foostrainer app in the Android store.

### M3: iOS

* Fix icons (done).
* Figure out when/why notification doesn't show (done).
* Remove extra UI from the notification (done).
* Automate screenshots to make releases simpler (done).
* Add fastlane for pushing changes.
  https://fastlane.tools/
  https://docs.fastlane.tools/getting-started/ios/appstore-deployment/

### M4: custom drills

* Allow creation of new drills.
* Allow save and restoration of drills across devices.


