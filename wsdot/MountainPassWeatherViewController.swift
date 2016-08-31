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

class MountainPassWeatherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    let cellIdentifier = "PassForecastCell"

    var passItem : MountainPassItem = MountainPassItem()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        let mountainPassTabBarContoller = self.tabBarController as! MountainPassTabBarViewController
        passItem = mountainPassTabBarContoller.passItem
        
        tableView.rowHeight = UITableViewAutomaticDimension
 
    }
    
    // MARK: Table View Data source methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passItem.forecast.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! ForecastCell
        
        let forecast = passItem.forecast[indexPath.row]
        
        cell.dayLabel.text = forecast.day
        cell.forecastLabel.text = forecast.forecastText
        cell.weatherIconView.image = UIImage(named: WeatherUtils.getIconName(forecast.forecastText, title: forecast.day))
        
        return cell
    }
}