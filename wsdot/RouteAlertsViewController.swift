//
//  RouteAlertsViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 7/21/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit

class RouteAlertsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet var tableView: UITableView!
    
    let cellIdentifier = "RouteAlerts"

    var alertItems : [FerriesRouteAlertItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let routeTabBarContoller = self.tabBarController as! RouteTabBarViewController
        alertItems = (routeTabBarContoller.routeItem?.routeAlerts)!
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        let attrStr = try! NSAttributedString(
            data: alertItems[indexPath.row].alertFullText.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        cell.textLabel?.text = attrStr.string
        
        print(alertItems[indexPath.row].alertFullText)
        
        cell.detailTextLabel?.text = "Published " + TimeUtils.timeSinceDate(TimeUtils.parseJSONDate(alertItems[indexPath.row].publishDate), numericDates: false)
        
        return cell
    }
}

