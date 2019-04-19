# WSDOT iOS App #

Washington State Traveler information provide by The Washington State Department of Transportation.

* Written in Swift 4.2
* Developed with Xcode 10.1

Features - [View on the App Store](https://itunes.apple.com/us/app/wsdot/id387209224?mt=8)
----------------------------------
* Traffic Map with highway cameras, real-time alerts and traffic conditions.
* Ferry schedules, alerts and VesselWatch.
* Mountain Pass condition and weather reports.
* WSDOT Social media feeds for the latest news.
* Toll Rates.
* Canadian Border Waits.
* Amtrak Cascades Schedules. 

Setup
-----
This project uses [CocoaPods](https://cocoapods.org/) for dependency management.

* Run `pod install` in the project directory to set up the workspace.
* Open the `WSDOT.xcworkspace` project in Xcode to get the CocoaPods workspace. 
* You will need to add a GoogleService-Info.plist file and add API keys to ApiKeys.swift.

Dependencies
------------
* [Firebase/Core](https://firebase.google.com/docs/ios/setup)
* [Firebase/AdMob](https://firebase.google.com/docs/admob/)
* [GoogleMaps](https://developers.google.com/maps/documentation/ios-sdk/)
* [Google Maps iOS Utils](https://github.com/googlemaps/google-maps-ios-utils)
* [GoogleAnalytics](https://developers.google.com/analytics/devguides/collection/ios/v3/?ver=swift)
* [Alamofire 3.4.1](https://github.com/Alamofire/Alamofire)
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
* [RealmSwift](https://realm.io/docs/swift/latest/)
* [SDWebImage](https://github.com/rs/SDWebImage)

Contributing
------------

Find a bug? Got an idea? Send us a pull request or open an issue and we'll take a look.

License
-------

Copyright (c) 2016 Washington State Department of Transportation

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>
