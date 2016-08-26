//
//  MountainPassReport.swift
//  WSDOT
//
//  Created by Logan Sims on 8/25/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MountainPassReportViewController: UIViewController {

    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var updatedLabel: UILabel!
    @IBOutlet weak var weatherDetailsLabel: UILabel!
    @IBOutlet weak var templabel: UILabel!
    @IBOutlet weak var elevationLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!
    @IBOutlet weak var restrictionOneTitleLabel: UILabel!
    @IBOutlet weak var restrictionOneLabel: UILabel!
    @IBOutlet weak var restrictionTwoTitleLabel: UILabel!
    
    @IBOutlet weak var restrictionTwoLabel: UILabel!
    
    var passItem : MountainPassItem = MountainPassItem()
    
    override func viewDidLoad() {
        
        let mountainPassTabBarContoller = self.tabBarController as! MountainPassTabBarViewController
        passItem = mountainPassTabBarContoller.passItem
 
        updatedLabel.text = "Updated " + TimeUtils.timeAgoSinceDate(passItem.dateUpdated, numericDates: false)
        
        if (passItem.forecast.count > 0){
            weatherDetailsLabel.text = passItem.forecast[0].forecastText
        } else {
            weatherDetailsLabel.text = "N/A"
        }
        
        if let temp = passItem.temperatureInFahrenheit.value{
            templabel.text = String(temp) + "°F"
        } else {
            templabel.text = "N/A"
        }
        
        elevationLabel.text = String(passItem.elevationInFeet) + " ft"
        conditionsLabel.text = passItem.roadCondition
        restrictionOneTitleLabel.text = "Restrictions " + passItem.restrictionOneTravelDirection
        restrictionOneLabel.text = passItem.restrictionOneText
        restrictionTwoTitleLabel.text = "Restrictions " + passItem.restrictionTwoTravelDirection
        restrictionTwoLabel.text = passItem.restrictionTwoText
 
        // Ad Banner
        bannerView.adUnitID = ApiKeys.wsdot_ad_string
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
 
 
    }
    
}