# FoosTrainer v3

FoosTrainer v3 is a redesign of the original FoosTrainer app for Android.

The goals for the redesign:

* Cleaner, more modern mobile UI.
* Fix bugs with delayed timers on some devices.
* Support custom drills and timings.
* Prepare for an eventual iOS port.

## Generate Code

Automatic code generation is used for SQL (via Floor library)
and JSON (via JSON serialization library).

This may prompt you to delete and recreate certain generated files.

```
flutter packages pub run build_runner build
```

## Run Unit Tests

```
flutter test
```

## Run On-Device tests

Start a simulator, or attach a real device. Then run

```
flutter drive \
    --driver=test_driver/integration_test.dart  \
    --target=integration_test/all_test.dart
```

For faster edit/test cycle, maybe try instructions from here:

https://medium.com/flutter-community/hot-reload-for-flutter-integration-tests-e0478b63bd54

In one window, start the app
```
flutter run --observatory-port 8888 --disable-service-auth-codes \
    test_driver/integration_test.dart
```

In another window, start the tests:
```
flutter drive --use-existing-app=http://127.0.0.1:8888/ \
    --driver test_driver/all_test.dart
```

Press 'R' in the app window to hot restart the app. Press '?' for additional commands.

Note that the well-documented version of the 'flutter drive' command  
does not work for older versions of flutter, due to https://github.com/flutter/flutter/issues/24703.
Newer versions of flutter have this fixed.

## Release Build - Android

This will build and install the app to a locally connected android device.

```
bash tools/android-prod-build.sh --device-id *id*
```

## iOS magic

Sometimes running "flutter run" for an iOS device just works. Other times, you
need something like this:

```
cd ios
rm Podfile.lock
rm -rf Pods
pod cache clean --all
pod deintegrate
pod repo update
pod setup
pod install
flutter run
```

To install a release build on iOS, sometimes this comes in handy:

```
bash tool/ios-release-build.sh
```

Another approach, from XCode UI:

```
Product > Archive
Window > Organizer
- Distribute App > Ad Hoc
- Distribute
- (click through)
- (select download location)
- ideviceinstaller -i (download location)/FoosTrainer.ipa
```

## Update Screenshots after UI Change

```
pub global activate screenshots
~/.pub-cache/bin/screenshots
```

If screenshot updates fail, check a few things:

* do the emulator images start up? Test them from XCode/Android Studio.
* doing a clean boot or reset of the emulator images sometimes helps.
* for Android, make sure that there is a Quickboot snapshot configured for
  each virtual device, but that the devices are not configured to save new
  snapshots.  This is controlled via the Snapshot settings, and needs to be
  set separately for each device.
* screenshots_test.dart might need edits for new navigation.
* flutter_driver tests are a bundle of race conditions, and a single flaky
  test can make everything much less reliable.

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

### M5: Progress Tracking

* Record practice time and accuracy.

### M6: i18n

* Why not...? seems like a larger user base.

### M7: custom drills

* Allow creation of new drills.
* Allow save and restoration of drills across devices.


