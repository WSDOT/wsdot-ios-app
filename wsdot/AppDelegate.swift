//
//  AppDelegate.swift
//  wsdot
//
//  Created by Logan Sims on 6/28/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        CachesStore.initCacheItem()
        
        FIRApp.configure()
        GADMobileAds.configureWithApplicationID(ApiKeys.wsdot_ad_string);
        
        return true
    }
    
    func applicationDidFinishLaunching(application: UIApplication) {
        FerryRealmStore.flushOldData()
        CamerasStore.flushOldData()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        FerryRealmStore.flushOldData()
        CamerasStore.flushOldData()
    }
    
    
}

