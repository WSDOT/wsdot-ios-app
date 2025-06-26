//
//  MountainPassWeatherViewController.swift
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

import Foundation
import UIKit
import GoogleMobileAds

class MountainPassWeatherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BannerViewDelegate{

    let cellIdentifier = "PassForecastCell"

    let refreshControl = UIRefreshControl()
    
    var passItem : MountainPassItem = MountainPassItem()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: AdManagerBannerView!
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        let mountainPassTabBarContoller = self.tabBarController as! MountainPassTabBarViewController
        
        passItem = mountainPassTabBarContoller.passItem
        
        tableView.rowHeight = UITableView.automaticDimension
 
        // refresh controller
        refreshControl.addTarget(self, action: #selector(refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.getAdId()
        bannerView.adSize = getFullWidthAdaptiveAdSize()
        bannerView.rootViewController = self
        let request = AdManagerRequest()
        request.customTargeting = ["wsdotapp":"passes"]
        
        bannerView.load(request)
        bannerView.delegate = self
 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "PassForecast")
    }
    
    
    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        refresh(true)
    }
    
    func refresh(_ force: Bool) {
        
        // refresh weather report
        DispatchQueue.global().async { [weak self] in
            MountainPassStore.updatePasses(true, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            
                            if let passItem = (MountainPassStore.getPasses().filter{ $0.id == selfValue.passItem.id }.first) {
                                selfValue.passItem = passItem
                                if selfValue.tableView != nil {
                                    selfValue.tableView.reloadData()
                                }
                            }
                            selfValue.refreshControl.endRefreshing()
                        }
                      
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.passes, message: WSDOTErrorStrings.passReport)
                        }
                    }
                }
            })
        }
    }
    
    // MARK: Table View Data source methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passItem.forecast.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ForecastCell
        
        let forecast = passItem.forecast[indexPath.row]
        
        cell.dayLabel.text = forecast.day
        cell.forecastLabel.text = forecast.forecastText
        
        // Check first sentence in forecast for icon match
        if ((UIImage(named: WeatherUtils.getForecastIconName(forecast.forecastText, title: forecast.day, index: 0))) != nil) {
            cell.weatherIconView.image = UIImage(named: WeatherUtils.getForecastIconName(forecast.forecastText, title: forecast.day, index: 0))

        }
        
        // Check second sentence in forecast for icon match
        else {
            cell.weatherIconView.image = UIImage(named: WeatherUtils.getForecastIconName(forecast.forecastText, title: forecast.day, index: 1))
        }
        
        
        return cell
    }
}
