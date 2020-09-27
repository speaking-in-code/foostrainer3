#!/bin/bash

set -e

function clean() {
  flutter clean
}

function unit_test() {
  flutter test
}

function screenshots() {
  flutter pub global run screenshots:main
}

function bump_version() {
  echo "Updating version and changelog."
  (cd android && bundle exec fastlane bump_version)
  (cd android && bundle exec fastlane make_changelog)
}

function build_releases() {
  echo "Building for iOS"
  flutter build ios --release
  echo "Building for Android"
  flutter build appbundle --release
}

function upload_android_beta() {
  echo "Uploading to Android beta track"
  (cd android && bundle exec fastlane beta)
}

function upload_ios_beta() {
  echo "Uploading to iOS beta track"
  (cd ios && bundle exec fastlane beta)
}

clean
#unit_test
#screenshots
bump_version
build_releases
upload_android_beta
upload_ios_beta
