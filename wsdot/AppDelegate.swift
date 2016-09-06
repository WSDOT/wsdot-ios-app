//
//  AppDelegate.swift
//  wsdot
//
//  Created by Logan Sims on 6/28/16.
//  Copyright © 2016 wsdot. All rights reserved.
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
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        
        gai.dryRun = ApiKeys.analytics_dryrun
        
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
        gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release

        
        return true
    }
    
    func applicationDidFinishLaunching(application: UIApplication) {
        FerryRealmStore.flushOldData()
        CamerasStore.flushOldData()
        TravelTimesStore.flushOldData()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        FerryRealmStore.flushOldData()
        CamerasStore.flushOldData()
        TravelTimesStore.flushOldData()
    }
}