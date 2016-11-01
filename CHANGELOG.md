# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

[Unreleased]: 

### Changed
* Ferry and Amtrak schedules no longer conevrt to users timezone.

## [5.0.2] - 2016-10-26

### Changed
* Sailing spaces now only pulls spaces for that route.
* Now only loads favorites data that users actually favorited. Used to load all data for all possible favorite items.
* Updated pods.
* NSTimer deinit logic in Vessel Watch. 
* Better connection error handling for sailing spaces. Use to report internet connectino error for every failed update timer task.

### Fixed
* Updated to Firebase 3.7.1 (Fixed an issue that causes a crash for some apps that call FirebaseAnalytics. Stack traces show that the crash occurs in -[FIRAAlarm cancel])
* Possible fix for a crash when updated mountain pass information. Date format crash.

## [5.0.1] - 2016-10-20

### Added
* VoiceOver improvements for ad banners and alerts ticker.
* Sailing spaces now auto update every minute.

### Changed
* Highest alerts page indicator is now gray for better contrast.
* The sailing spaces graphic height has been increased.
* Traffic Alerts are now sorted by most recent.

### Fixed
* App correctly uses cached data when offline.
* Departure annotations will now show with sailing spaces.
* Full-screen button now shows on app start up.
* Travel times with no data now show "N/A" instead of "0 min".
* Fixed text cut off in Route Schedules on small screens.

## [5.0.0] - 2016-10-12
### Added
* New Codebase.
* Camera icons on the Traffic Map can now be clustered.
* Split screen layout for iPhone Plus landscape and iPad screens. 
* Can now toggle all map markers on/off.
* New organization of Pass Reports.
* New Amtrak Schedules. Now Shows all legs of a trip in detail. 
* Ferry Alert tabs now will display a badge with the number of active alerts.
* Added WSDOT North Traffic Twitter account. 
* Added WSDOT Flickr account to Social Media Section.
* Bug report template added in the About section.
