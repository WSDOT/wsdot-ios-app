//
//  AppDelegate.swift
//  wsdot
//
//  Copyright (c) 2016 Washington State Department of Transportation
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//

import UIKit
import Firebase
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        CachesStore.initCacheItem()
        
        GMSServices.provideAPIKey(ApiKeys.google_key)
        FIRApp.configure()
        GADMobileAds.configureWithApplicationID(ApiKeys.wsdot_ad_string);
        
        if (GoogleAnalytics.analytics_enabled){
            
            // Configure tracker from GoogleService-Info.plist.
            var configureError:NSError?
            GGLContext.sharedInstance().configureWithError(&configureError)
            assert(configureError == nil, "Error configuring Google services: \(configureError)")
            
            // Optional: configure GAI options.
            let gai = GAI.sharedInstance()
            
            if (GoogleAnalytics.analytics_dryrun){
                gai.dryRun = GoogleAnalytics.analytics_dryrun
                gai.logger.logLevel = GAILogLevel.Verbose
            }
            gai.trackUncaughtExceptions = true  // report uncaught exceptions
            
        }
        
        // Reset Warning each time app starts
        NSUserDefaults.standardUserDefaults().setObject(false, forKey: UserDefaultsKeys.hasSeenWarning)
        
        return true
    }
    
    func applicationDidFinishLaunching(application: UIApplication) {
        FerryRealmStore.flushOldData()
        CamerasStore.flushOldData()
        TravelTimesStore.flushOldData()
        HighwayAlertsStore.flushOldData()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        FerryRealmStore.flushOldData()
        CamerasStore.flushOldData()
        TravelTimesStore.flushOldData()
        HighwayAlertsStore.flushOldData()
    }
}
