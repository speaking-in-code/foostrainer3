#!/bin/bash

set -e

BUNDLE="build/app/outputs/bundle/release/app-release.aab"
APKS="build/app/outputs/bundle/release/app-release.apks"

echo Building release build.
flutter build appbundle

echo Extracting APKs.
bundletool build-apks \
    --bundle "${BUNDLE}" \
    --connected-device \
    --overwrite \
    --output "${APKS}" \
    $* 

echo Installing to device.
bundletool install-apks \
    --apks "${APKS}" \
    $* 
