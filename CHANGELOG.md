# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

[Unreleased]:

### Added
* Border waits can be added to the favorites list.

### Removed
* SCLAlertView library. Replaced with a simple alert view

## [5.11.4]

### Added
* Firebase Crashlytics
* Firebase Performance monitoring

### Fixed
* Fixes crash when using new date format for ferry bulletins.

## [5.11.3] 2019-01-09

### Changed
* Ferry alert bulletins are now available on the sailings screen.
* Ferry drop down options are now screen aware. Disappear when they are not needed

## [5.11.1] 2018-12-14

### Fixed
* Crash when refreshing pass cameras.
* crash when camera images fail to load.

## [5.11.0] 2018-12-05

### Changed
* Traffic camera images will now fill the width of the device screen.

## [5.10.2] 2018-10-30

### Fixed
* Terminal cameras list now updates when a terminal is selected.

## [5.10.1] 2018-10-27

### Fixed
* Vessel Watch opens to correct location for ANA-SJ routes.

## [5.10.0] 2018-10-22

### Changed
* Ferries section layout. 
* Vessel watch is now a tab on the departures screen.
* Ferry alerts now display as a button on the route table cell.
* Removes sailings screen in favor of drop down on departures screen.
* reservations link is now located at the top of the routes screen.

## [5.9.0] 2018-08-28

### Added 
* I-405 Express Toll Lanes and SR 167 HOT Lanes rates in the toll rates section

## [5.8.5] 2018-08-20

### Changed
* Replaces use of the Google Static Maps API with a native Google Map view with touch events disabled. 

## [5.8.4] 2018-07

### Added
* Everett to go to locations

### Changed
* Swift 4 compatiabilty

### Fixed
* Go to locations not working when menu presented as pop up.

## [5.8.3] 2018-06-14

### Changed
* Ferries section updated to handle new date format coming in the future. The current format is a .NET style date string returned from the API. The new format that will be added in the future is "yyyy-MM-dd hh:mm a"

## [5.8.2] 2018-06-08

### Added
* Push notification event tracking. 

### Fixed
* Better analytics event labeling for notification subscriptions.

## [5.8.1] 2018-06-04

### Added
* Low impact alert icons

### Fixed
* Crash in ferry schedules when auto scrolling before tableview is ready.

## [5.8.0] 2018-05-29

### Added
* Push Notifications

## [5.7.3] 2017-05-01

### Added
* WSF contact info.

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
