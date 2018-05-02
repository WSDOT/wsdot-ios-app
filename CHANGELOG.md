# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

[Unreleased]: 

## [5.7.3] 2017-05-01
* Adds WSF contact info.

## [5.7.2] 2017-04-16

### Added
* Refresh action on pass report screen.

## [5.7.1] 2017-03-19

### Added
* Users can now swipe through their favorite cameras.

## [5.7.0] 2017-03-09

### Changed
* New travel times look. Travel times are now grouped by start and end locations.

## [5.6.0] 2017-02-20

### Added
* Past sailing times for the current day.
* Events banner & event theming. 

## [5.5.1] 2017-11-06

### Added
* New Amtrak Cascades train numbers.

## [5.5.0] 2017-10-23

### Changed
* Removed social media section. Facebook, twitter, blogger and Youtube are not in the Happening now section.
* External links now use a SFSafariViewController to display content.

## [5.4.3] 2017-09-13

### Added
* Enabled compass button on maps.

## [5.4.2] 2017-08-30

### Added
* Added HERO number and online form.
* Advertisement updates.

## [5.4.0] 2017-08-07

### Added
* travel charts section.

## [5.3.1] 2017-06-29

### Changed
* updated toll rates for 2017

### Fixed
* Vessel Watch permission error

## [5.3.0] 2017-06-21

### Added
* support for targeted ads

### Changed
* updated WSDOT mission statment.

## [5.2.0] 2017-05-04

### Added
* My Routes section. Users can record routes and let the WSDOT app add content on their route to their favorites, as well as check for traffic alerts on thir route.
* Favorites Settings. From this menu users can rearrage their favorites and clear their favorites list.
* Renaming favorite locations.
* MyGoodToGo.com link.

## [5.1.0] 2017-01-30
### Added
* When tapping overlapping traffic alerts, a list of all the overlapping alerts will open.
* WSDOT East Twitter account.

### Changed
* Changed speed alert text.

### Fixed
* Flickr feed was requesting JSON response as a string, not a JSON object. This has been fixed.

## [5.0.7] - 2017-01-03

## Fixed
* Crash when adding a favorite location on iOS 8.3.
* Layout improvments for small and large screens.
* Dislpayed correct alert icon for road closures. 

## [5.0.6] - 2016-12

## Changed
* Migrated Realm DB to version 1. Changed pass items to only hold a list of camera IDs and not cameraItems so as to keep from overwriting data pulled in from the CamerasStore.

## Fixed
* Pass cameras will now save to favorites and plot correctly because of the above change.
* Pass report text cut issue fixed.
* Rest areas now show correct icon.

## [5.0.5] - 2016-11-28

## Fixed
* Added timestamp to camera urls to prevent SDWebImage from agressively caching camera images. 

## [5.0.4] - 2016-11-16

## Fixed
* Amtrak Cascades 516 train is longer labeled as a bus servcie.
* Pass reports now correctly save temperatures from the json feed. 

## [5.0.3] - 2016-10-31

### Changed
* Ferry and Amtrak schedules no longer conevrt to users timezone.
* Updated Realm Swift to version 2.0.3

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
