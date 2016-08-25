//
//  MountainPassDetailsViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/24/16.
//  Copyright © 2016 WSDOT. All rights reserved.
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
        }else{
            favoriteBarButton.image = UIImage(named: "icStarSmall")
        }
        self.navigationItem.rightBarButtonItem = favoriteBarButton
    }
    
    func updateFavorite(sender: UIBarButtonItem) {
        if (passItem.selected){
            MountainPassStore.updateFavorite(passItem, newValue: false)
            favoriteBarButton.image = UIImage(named: "icStarSmall")
        }else {
            MountainPassStore.updateFavorite(passItem, newValue: true)
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
        }
    }
    
}