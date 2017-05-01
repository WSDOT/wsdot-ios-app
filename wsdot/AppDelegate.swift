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
import GoogleMobileAds
import UserNotifications
import GoogleMaps
import RealmSwift
import Realm
import EasyTipView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        migrateRealm()
        CachesStore.initCacheItem()
        
        GMSServices.provideAPIKey(ApiKeys.getGoogleAPIKey())
        FIRApp.configure()
        GADMobileAds.configure(withApplicationID: ApiKeys.getAdId());
        
        // EasyTipView Setup
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top

        // Make these preferences global for all future EasyTipViews
        EasyTipView.globalPreferences = preferences
        
        if (GoogleAnalytics.analytics_enabled){
            
            // Configure tracker from GoogleService-Info.plist.
            var configureError:NSError?
            GGLContext.sharedInstance().configureWithError(&configureError)
            assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
            
            // Optional: configure GAI options.
            if let gai = GAI.sharedInstance() {
                 if (GoogleAnalytics.analytics_dryrun){
                     gai.dryRun = GoogleAnalytics.analytics_dryrun
                     gai.logger.logLevel = GAILogLevel.verbose
                 }
                 gai.trackUncaughtExceptions = true  // report uncaught exceptions
            }
        }
        // Reset Warning each time app starts
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.hasSeenWarning)
        
        return true
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        FerryRealmStore.flushOldData()
        CamerasStore.flushOldData()
        TravelTimesStore.flushOldData()
        HighwayAlertsStore.flushOldData()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        FerryRealmStore.flushOldData()
        CamerasStore.flushOldData()
        TravelTimesStore.flushOldData()
        HighwayAlertsStore.flushOldData()
    }
    
    func migrateRealm(){
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 2,
            
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    // The enumerateObjects(ofType:_:) method iterates
                    // over every MountainPassItem object stored in the Realm file
                    migration.enumerateObjects(ofType: MountainPassItem.className()) { oldObject, newObject in
                        // pull the camera ids from the old field and place it into the new
                        let oldCameras = oldObject!["cameras"] as! List<DynamicObject>
                        let passCameraIds = newObject!["cameraIds"] as! List<DynamicObject>
                        for camera in oldCameras {
                            let newPassCameraId = migration.create(PassCameraIDItem.className())
                            newPassCameraId["cameraId"] = camera["cameraId"] as! Int
                            passCameraIds.append(newPassCameraId)
                        }
                    }
                }
                
                if (oldSchemaVersion < 2) {
                    // The enumerateObjects(ofType:_:) method iterates
                    // over every TravelTime object stored in the Realm file
                    migration.enumerateObjects(ofType: TravelTimeItem.className()) { oldObject, newObject in
                        // Add start/end lat/long to travel times
                        newObject!["startLatitude"] = 0.0
                        newObject!["endLatitude"] = 0.0
                        newObject!["startLongitude"] = 0.0
                        newObject!["endLongitude"] = 0.0
                    }
                }
        })
    }
}
