//
//  RouteTabViewController.swift
//  WSDOT
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
            self.tabBar.items?[1].isEnabled = false
        }
        
        favoriteBarButton.action = #selector(RouteTabBarViewController.updateFavorite(_:))
        favoriteBarButton.target = self
        favoriteBarButton.tintColor = Colors.yellow
        
        if (routeItem.selected){
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
            favoriteBarButton.accessibilityLabel = "remove from favorites"
        }else{
            favoriteBarButton.image = UIImage(named: "icStarSmall")
            favoriteBarButton.accessibilityLabel = "add to favorites"
        }
        
        self.navigationItem.rightBarButtonItem = favoriteBarButton
    }
    
    func updateFavorite(_ sender: UIBarButtonItem) {
        if (routeItem.selected){
            FerryRealmStore.updateFavorite(routeItem, newValue: false)
            favoriteBarButton.image = UIImage(named: "icStarSmall")
            favoriteBarButton.accessibilityLabel = "add to favorites"
        }else {
            FerryRealmStore.updateFavorite(routeItem, newValue: true)
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
            favoriteBarButton.accessibilityLabel = "remove from favorites"
        }
    }
}
