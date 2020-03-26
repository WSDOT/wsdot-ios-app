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

class MountainPassReportViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var bannerView: DFPBannerView!
    
    @IBOutlet weak var updatedLabel: UILabel!
    @IBOutlet weak var weatherDetailsLabel: UILabel!
    @IBOutlet weak var templabel: UILabel!
    @IBOutlet weak var elevationLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!
    @IBOutlet weak var restrictionOneTitleLabel: UILabel!
    @IBOutlet weak var restrictionOneLabel: UILabel!
    @IBOutlet weak var restrictionTwoTitleLabel: UILabel!
    
    @IBOutlet weak var restrictionTwoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mountainPassTabBarContoller = self.tabBarController as! MountainPassTabBarViewController

        updateView(withPassItem: mountainPassTabBarContoller.passItem)
 
        // Ad Banner
        bannerView.adUnitID = ApiKeys.getAdId()
        bannerView.rootViewController = self
        let request = DFPRequest()
        request.customTargeting = ["wsdotapp":"passes"]
        
        bannerView.load(request)
        bannerView.delegate = self
        
    }
    
    func updateView(withPassItem: MountainPassItem) {
 
        updatedLabel.text = "Updated " + TimeUtils.formatTime(withPassItem.dateUpdated, format: "MMMM dd, YYYY h:mm a")
        
        if (withPassItem.weatherCondition != ""){
            weatherDetailsLabel.text = withPassItem.weatherCondition
        } else if (withPassItem.forecast.count > 0){
            weatherDetailsLabel.text = withPassItem.forecast[0].forecastText
        } else {
            weatherDetailsLabel.text = "N/A"
        }
        
        if let temp = withPassItem.temperatureInFahrenheit.value{
            templabel.text = String(temp) + "°F"
        } else {
            templabel.text = "N/A"
        }
        
        elevationLabel.text = String(withPassItem.elevationInFeet) + " ft"
        conditionsLabel.text = withPassItem.roadCondition
        restrictionOneTitleLabel.text = "Restrictions " + withPassItem.restrictionOneTravelDirection + ":"
        restrictionOneLabel.text = withPassItem.restrictionOneText
        restrictionTwoTitleLabel.text = "Restrictions " + withPassItem.restrictionTwoTravelDirection + ":"
        restrictionTwoLabel.text = withPassItem.restrictionTwoText
    
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isAccessibilityElement = true
        bannerView.accessibilityLabel = "advertisement banner."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "PassReport")
    }
    
}
