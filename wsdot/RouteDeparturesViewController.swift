//
//  RouteDetailsViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 7/18/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
import UIKit
import GoogleMobileAds

class RouteDeparturesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "RouteDepartures"

    var routeItem : FerriesRouteScheduleItem? = nil
    var departingTerminal : String? = nil
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = departingTerminal
        
        print("departing from")
        print(departingTerminal)
        
        
        bannerView.adUnitID = "ad_string"
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
        
    }
    
    // MARK: -
    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0 // TODO
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        return cell
    }
}
