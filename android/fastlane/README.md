fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## Android
### android changelog
```
fastlane android changelog
```
Test changelog functionality
### android make_changelog
```
fastlane android make_changelog
```

### android bump_version
```
fastlane android bump_version
```
Increment build version
### android beta
```
fastlane android beta
```
Submit a new beta Build to Google Play Store
### android prod
```
fastlane android prod
```
Promote beta version to prod

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
