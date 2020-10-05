#!/bin/bash

set -e

readonly RELEASE="$1"
if [[ "${RELEASE}" = "" ]]; then
  echo "Usage: beta.sh release_name" 1>&2
  exit 1
fi

function clean() {
  flutter clean
}

function unit_test() {
  flutter test
}

# Uses screenshots to start a few simulators and run our integration tests.
# Does not take app store screenshots.
function integration_test() {
  flutter pub global run screenshots:main -c integration_test.yaml -m archive
}

# Generate app store screenshots.
function screenshots() {
  #flutter run ../screenshots/bin/main.dart
  flutter pub global run screenshots:main
}

function bump_version() {
  echo "Updating version and changelog."
  (cd android && bundle exec fastlane bump_version "release:${RELEASE}")
  (cd android && bundle exec fastlane make_changelog "release:${RELEASE}")
}

function build_releases() {
  echo "Building for iOS"
  flutter build ios --release
  echo "Building for Android"
  flutter build appbundle --release
}

function upload_android_beta() {
  echo "Uploading to Android beta track"
  (cd android && bundle exec fastlane beta "release:${RELEASE}")
}

function upload_ios_beta() {
  echo "Uploading to iOS beta track"
  (cd ios && bundle exec fastlane beta "release:${RELEASE}")
}

clean
unit_test
#integration_test
screenshots
bump_version
build_releases
upload_android_beta
upload_ios_beta
