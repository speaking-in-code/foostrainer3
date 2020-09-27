#!/bin/bash

set -e

function unit_test() {
  flutter test
}

function screenshots() {
  flutter pub global run screenshots:main
}

function bump_version() {
  echo
  #(cd android && bundle exec fastlane bump_version)
  #(cd android && bundle exec fastlane make_changelog)
}

function build_releases() {
  echo
  #flutter build appbundle --release
  #flutter build ios --release
}

function upload_android_beta() {
  (cd android && bundle exec fastlane beta)
}

function upload_ios_beta() {
  echo
}

#unit_test
#screenshots
#bump_version
#build_releases
upload_android_beta
