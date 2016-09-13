//
//  MountainPassDetailsViewController.swift
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
import GoogleMobileAds

class MountainPassTabBarViewController: UITabBarController{
    
    var passItem = MountainPassItem()
    
    let favoriteBarButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = passItem.name
        
        if (passItem.forecast.count == 0){
            self.tabBar.items?[1].enabled = false
        }
        
        if (passItem.cameras.count == 0){
            self.tabBar.items?[2].enabled = false
        }
        
        favoriteBarButton.action = #selector(MountainPassTabBarViewController.updateFavorite(_:))
        favoriteBarButton.target = self
        
        if (passItem.selected){
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
            favoriteBarButton.accessibilityLabel = "remove from favorites"
        }else{
            favoriteBarButton.image = UIImage(named: "icStarSmall")
            favoriteBarButton.accessibilityLabel = "add to favorites"
        }
        self.navigationItem.rightBarButtonItem = favoriteBarButton
    }
    
    func updateFavorite(sender: UIBarButtonItem) {
        if (passItem.selected){
            MountainPassStore.updateFavorite(passItem, newValue: false)
            favoriteBarButton.image = UIImage(named: "icStarSmall")
            favoriteBarButton.accessibilityLabel = "add to favorites"
        }else {
            MountainPassStore.updateFavorite(passItem, newValue: true)
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
            favoriteBarButton.accessibilityLabel = "remove from favorites"
        }
    }
    
}