//
//  MountainPassReport.swift
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
        super.viewDidLoad()
        let mountainPassTabBarContoller = self.tabBarController as! MountainPassTabBarViewController
        passItem = mountainPassTabBarContoller.passItem
 
        updatedLabel.text = "Updated " + TimeUtils.fullTimeStamp(passItem.dateUpdated)
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Mountain Passes/Report")
    }
    
}