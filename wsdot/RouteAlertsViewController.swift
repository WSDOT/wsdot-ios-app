//
//  RouteAlertsViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 7/21/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit

class RouteAlertsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, INDLinkLabelDelegate {

    
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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! LinkCell
        
        let htmlStyleString = "<style>body{font-family: '\(cell.linkLabel.font.fontName)'; font-size:\(cell.linkLabel.font.pointSize)px;}</style>"
        
        let htmlString = htmlStyleString + alertItems[indexPath.row].alertFullText
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        cell.linkLabel.attributedText = attrStr
        cell.linkLabel.delegate = self
        
        return cell
    }
    
    // MARK: INDLinkLabelDelegate
    
    func linkLabel(label: INDLinkLabel, didLongPressLinkWithURL URL: NSURL) {
        let activityController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
        self.presentViewController(activityController, animated: true, completion: nil)
    }
    
    func linkLabel(label: INDLinkLabel, didTapLinkWithURL URL: NSURL) {
        UIApplication.sharedApplication().openURL(URL)
    }
}

