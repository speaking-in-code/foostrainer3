#!/bin/bash

set -e

readonly ARCHIVE_PATH=build/ios/archive/FoosTrainer.xcarchive
readonly EXPORT_DIR=build/ios/FoosTrainer.dir
readonly EXPORT_IPA=build/ios/FoosTrainer.ipa

# This creates the .xcarchive, not the IPA.
flutter build ipa

# This makes the directory structure for the IPA.
xcodebuild -exportArchive \
  -allowProvisioningUpdates \
  -archivePath "${ARCHIVE_PATH}" \
  -exportPath "${EXPORT_DIR}" \
  -exportOptionsPlist tools/ios-adhoc-export.plist

# This creates the ipa file.
mv "${EXPORT_DIR}/FoosTrainer.ipa" "${EXPORT_IPA}"

# Yay!
cat <<EOF
IPA file: ${EXPORT_IPA}. Install with:
ideviceinstaller -i "${EXPORT_IPA}"
EOF
