//
//  MountainPassWeatherViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/25/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class MountainPassWeatherViewController: UIViewController{

    var passItem : MountainPassItem = MountainPassItem()
    
    override func viewDidLoad() {
        
        let mountainPassTabBarContoller = self.tabBarController as! MountainPassTabBarViewController
        passItem = mountainPassTabBarContoller.passItem

 
    }
}