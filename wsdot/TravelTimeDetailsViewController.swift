//
//  TravelTimeDetailsViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/23/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class TravelTimeDetailsViewController: UIViewController {

    @IBOutlet weak var favoriteTabBarButton: UIBarButtonItem!
    var travelTime = TravelTimeItem()
    
    override func viewDidLoad() {

        title = travelTime.title

        if (travelTime.selected){
            favoriteTabBarButton.image = UIImage(named: "icStarSmallFilled")
        }else{
            favoriteTabBarButton.image = UIImage(named: "icStarSmall")
        }
    }
    
    @IBAction func updateFavorite(sender: UIBarButtonItem) {
        if (travelTime.selected){
            TravelTimesStore.updateFavorite(travelTime, newValue: false)
            favoriteTabBarButton.image = UIImage(named: "icStarSmall")
        }else {
            TravelTimesStore.updateFavorite(travelTime, newValue: true)
            favoriteTabBarButton.image = UIImage(named: "icStarSmallFilled")
        }
    }
}