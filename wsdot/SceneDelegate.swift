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

        let realm = try! Realm()
        let passItems = realm.objects(MountainPassItem.self)
        
     //   var passItems = realm.object(ofType: MountainPasses.self, forPrimaryKey: 0)
     //   if passItems == nil {
     //       passItems = try! realm.write { realm.create(MountainPasses.self, value: []) }
     //   }
    
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(
                rootView: HomeView(items: BindableResults<MountainPassItem>(results: passItems))
            )
            self.window = window
            window.makeKeyAndVisible()
        }
        
        MountainPassStore.updatePasses(true, completion: { error in
                if (error != nil) {
                    AlertMessages.getConnectionAlert(backupURL:WsdotURLS.passes, message: WSDOTErrorStrings.passReports)
                }
        })
        
    }
}
