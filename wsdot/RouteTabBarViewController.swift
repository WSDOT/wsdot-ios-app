//
//  RouteTabViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 7/21/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit

/*
 Modified UITabBarController with routeItem data to be accessed by child views,
 holds controller logic for adding route to favorites.
 */
class RouteTabBarViewController: UITabBarController {
    
    var routeItem : FerryScheduleItem = FerryScheduleItem()
    
    let favoriteBarButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = routeItem.routeDescription;
        
        if (routeItem.routeAlerts.count > 0){
            self.tabBar.items?[1].badgeValue = String(routeItem.routeAlerts.count)
        } else {
            self.tabBar.items?[1].enabled = false
        }
        
        favoriteBarButton.action = #selector(RouteTabBarViewController.updateFavorite(_:))
        favoriteBarButton.target = self
        
        if (routeItem.selected){
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
        }else{
            favoriteBarButton.image = UIImage(named: "icStarSmall")
        }
        
        self.navigationItem.rightBarButtonItem = favoriteBarButton
    }
    
    func updateFavorite(sender: UIBarButtonItem) {
        if (routeItem.selected){
            FerryRealmStore.updateFavorite(routeItem, newValue: false)
            favoriteBarButton.image = UIImage(named: "icStarSmall")
        }else {
            FerryRealmStore.updateFavorite(routeItem, newValue: true)
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
        }
    }
}