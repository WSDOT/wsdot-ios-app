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
    @IBOutlet weak var routeTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var updated: UILabel!
    @IBOutlet weak var currentTime: UILabel!

    var travelTime = TravelTimeItem()
    
    override func viewDidLoad() {

        title = travelTime.title

        routeTitle.text = travelTime.title
        subTitle.text = String(travelTime.distance) + " miles / " + String(travelTime.averageTime) + " min"
        updated.text = TimeUtils.timeAgoSinceDate(TimeUtils.formatTimeStamp(travelTime.updated), numericDates: false)
        currentTime.text = String(travelTime.currentTime) + " min"
 
        if (travelTime.averageTime > travelTime.currentTime){
            currentTime.textColor = Colors.tintColor
        } else if (travelTime.averageTime < travelTime.currentTime){
            currentTime.textColor = UIColor.redColor()
        } else {
            currentTime.textColor = UIColor.darkTextColor()
        }
        
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