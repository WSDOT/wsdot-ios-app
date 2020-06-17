//
//  HomeSceneDelegate.swift
//  WSDOT
//
//  Created by Logan Sims on 6/10/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//


import SwiftUI
import UIKit
import RealmSwift

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        UINavigationBar.appearance().backgroundColor = Colors.wsdotPrimary
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().barTintColor = Colors.wsdotPrimary
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        
        let realm = try! Realm()
        let passItems = realm.objects(MountainPassItem.self)
            .sorted(byKeyPath: "id", ascending: true)
            .sorted(byKeyPath: "selected", ascending: false)
        
        let schedules = realm.objects(FerryScheduleItem.self)
            .sorted(byKeyPath: "routeDescription", ascending: true)
            .sorted(byKeyPath: "selected", ascending: false)
        
        let alerts = realm.objects(HighwayAlertItem.self)
    
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(
                rootView: HomeView(
                    passes: BindableResults<MountainPassItem>(results: passItems),
                ferrySchedules: BindableResults<FerryScheduleItem>(results: schedules),
                alerts: BindableResults<HighwayAlertItem>(results: alerts))
            )
            self.window = window
            window.makeKeyAndVisible()
        }
        
        MountainPassStore.updatePasses(true, completion: { error in
            if (error != nil) {
                print("error fetching passes")
            }
        })
        
        FerryRealmStore.updateRouteSchedules(true, completion: { error in
            if (error != nil) {
                print("error fetching ferry schedules")
            }
        })
        
    }
}
