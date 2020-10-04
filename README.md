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

To install a release build on iOS, sometimes this comes in handy:

```
ideviceinstaller -i FoosTrainer.ipa
```

## Update Screenshots after UI Change

```
pub global activate screenshots
~/.pub-cache/bin/screenshots
```


## Production Release

Edit CHANGELOG.md to include a description of user-visible changes
for the new release. Pick a release name, e.g. 'M4'.

Then run

```
bash beta.sh <release-name>.
```

This runs unit tests and integration tests, updates screenshots,
builds release builds, and uploads to beta tracks for both iOS
and Google Play app stores.

Once beta testers are happy, promote to prod:

```
bash prod.sh
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

### M3: iOS (done)

* Fix icons
* Figure out when/why notification doesn't show.
* Remove extra UI from the notification.
* Automate screenshots to make releases simpler.
* Add fastlane for pushing changes.

### M4: feature requests/post-launch

* End-user feedback system (done.)
* Bing when timer starts (done.)
* Signal action with flash. (busted on Android.)
* Configurable timings (done)
* New screenshots. (done)

### M4.5: android flash

* Flash works now.

### M5: i18n

* Why not...? seems like a larger user base.

### M6: custom drills

* Allow creation of new drills.
* Allow save and restoration of drills across devices.


