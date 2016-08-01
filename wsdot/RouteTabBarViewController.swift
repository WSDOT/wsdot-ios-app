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
    
    var routeItem : FerriesRouteScheduleItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = routeItem?.routeDescription;
        
        if (routeItem!.routeAlerts.count > 0){
            self.tabBar.items?[1].badgeValue = String(routeItem!.routeAlerts.count)
        } else {
            self.tabBar.items?[1].enabled = false
        }
        
        let favoriteButton = UIButton()
        
        print(routeItem?.selected)
        
        if ((routeItem?.selected)!){
            favoriteButton.setImage(UIImage(named: "icFavoriteSelected"), forState: .Normal)
            favoriteButton.setImage(UIImage(named: "icFavoriteDefault"), forState: .Highlighted)
            favoriteButton.setImage(UIImage(named: "icFavoriteDefault"), forState: .Selected)
            favoriteButton.addTarget(self, action: #selector(RouteTabBarViewController.removeFavorite(_:)), forControlEvents: .TouchUpInside)
        }else{
            favoriteButton.setImage(UIImage(named: "icFavoriteDefault"), forState: .Normal)
            favoriteButton.setImage(UIImage(named: "icFavoriteSelected"), forState: .Highlighted)
            favoriteButton.setImage(UIImage(named: "icFavoriteSelected"), forState: .Selected)
            favoriteButton.addTarget(self, action: #selector(RouteTabBarViewController.addFavorite(_:)), forControlEvents: .TouchUpInside)
        }
        
        favoriteButton.sizeToFit()
        let favoritesNavItemButton = UIBarButtonItem()
        favoritesNavItemButton.customView = favoriteButton
        
        self.navigationItem.rightBarButtonItem = favoritesNavItemButton
    }
    
    // Sets selected attribute of the route item to true and calls DB update logic
    func addFavorite(sender: UIButton){
        
        sender.setImage(UIImage(named: "icFavoriteSelected"), forState: .Normal)
        sender.setImage(UIImage(named: "icFavoriteDefault"), forState: .Highlighted)
        sender.setImage(UIImage(named: "icFavoriteDefault"), forState: .Selected)
        sender.removeTarget(self, action: #selector(RouteTabBarViewController.addFavorite(_:)), forControlEvents: .TouchUpInside)
        sender.addTarget(self, action: #selector(RouteTabBarViewController.removeFavorite(_:)), forControlEvents: .TouchUpInside)
        routeItem?.selected = true
        
        print("fav Added!")
        print((routeItem?.routeId)!)
        RouteSchedulesStore.updateFavorite((routeItem?.routeId)!, newValue: true)
        
    }
    
    // Sets selected attribute of the route item to false and calls DB update logic
    func removeFavorite(sender: UIButton){
        sender.setImage(UIImage(named: "icFavoriteDefault"), forState: .Normal)
        sender.setImage(UIImage(named: "icFavoriteSelected"), forState: .Highlighted)
        sender.setImage(UIImage(named: "icFavoriteSelected"), forState: .Selected)
        sender.removeTarget(self, action: #selector(RouteTabBarViewController.removeFavorite(_:)), forControlEvents: .TouchUpInside)
        sender.addTarget(self, action: #selector(RouteTabBarViewController.addFavorite(_:)), forControlEvents: .TouchUpInside)
        routeItem?.selected = false
 
        print("fav removed!")
        RouteSchedulesStore.updateFavorite((routeItem?.routeId)!, newValue: false)
        
        
    }
    
    
    
}
