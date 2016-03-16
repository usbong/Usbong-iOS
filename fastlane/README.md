fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Runs all the tests
### ios beta
```
fastlane ios beta
```
Submit a new Beta Build to Apple TestFlight

This will also make sure the profile is up to date
### ios appstore_new_build
```
fastlane ios appstore_new_build
```
Deploy a new build to the App Store. Takes the following arguments: 
   :username the Apple ID to use to log into the developer portal for SIGH 
   :skip_snapshot set to true to skip SNAPSHOT
### ios appstore_new_version
```
fastlane ios appstore_new_version
```
Deploy a new version to the App Store. Takes the following arguments: 
   :username the Apple ID to use to log into the developer portal for SIGH 
   :skip_snapshot set to true to skip SNAPSHOT 
   :bump_type increment the version number with major, minor, or patch bump type
### ios appstore
```
fastlane ios appstore
```
Deploy current build to the App Store. Takes the following arguments: 
   :username the Apple ID to use to log into the developer portal for SIGH 
   :skip_snapshot set to true to skip SNAPSHOT
### ios increment_version_number
```
fastlane ios increment_version_number
```
Increment version with specified bump_type
### ios show_changelog
```
fastlane ios show_changelog
```
Show git commits since the last git tag
### ios generate_screenshots
```
fastlane ios generate_screenshots
```
Generate screenshots

----

This README.md is auto-generated and will be re-generated every time to run [fastlane](https://fastlane.tools).  
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).  
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane).