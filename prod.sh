#!/bin/bash

set -e

function release_android() {
  echo "Promoting Android beta to prod."
  (cd android && bundle exec fastlane prod)
}

function release_ios() {
  echo "Promoting iOS beta to prod."
  (cd ios && bundle exec fastlane prod)
}

release_android
release_ios
