//
//  AlertInAreaViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/22/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import UIKit

class AlertsInAreaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, INDLinkLabelDelegate {
    
    let cellIdentifier = "AlertCell"
    let SegueHighwayAlertViewController = "HighwayAlertViewController"
    
    var alerts = [HighwayAlertItem]()
    
    var trafficAlerts = [HighwayAlertItem]()
    var constructionAlerts = [HighwayAlertItem]()
    var specialEvents = [HighwayAlertItem]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {

        title = "Alerts In This Area"
        
        for alert in alerts{
            if alert.headlineDesc.containsString("construction") || alert.eventCategory == "Construction"{
                constructionAlerts.append(alert)
            }else if alert.eventCategory == "Special Event"{
                specialEvents.append(alert)
            }else {
                trafficAlerts.append(alert)
            }
        }

        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: -
    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch(section){
        case 0:
            return "Traffic Alerts"
        case 1:
            return "Construction"
        case 2:
            return "Special Events"
        default:
            return nil
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch(section){
            
        case 0:
            return trafficAlerts.count
        case 1:
            return constructionAlerts.count
        case 2:
            return specialEvents.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! LinkCell
        
        let htmlStyleString = "<style>body{font-family: '\(cell.linkLabel.font.fontName)'; font-size:\(cell.linkLabel.font.pointSize)px;}</style>"
        var htmlString = ""
        
        switch indexPath.section{
        case 0:
            htmlString = htmlStyleString + trafficAlerts[indexPath.row].headlineDesc
            break
        case 1:
            htmlString = htmlStyleString + constructionAlerts[indexPath.row].headlineDesc
            break
        case 2:
            htmlString = htmlStyleString + specialEvents[indexPath.row].headlineDesc
            break
        default:
            break
        }

        let attrStr = try! NSMutableAttributedString(
            data: htmlString.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        cell.linkLabel.attributedText = attrStr
        cell.linkLabel.delegate = self
        
        return cell
    }
    
    // MARK: -
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(SegueHighwayAlertViewController, sender: alerts[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Naviagtion
    // Get refrence to child VC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == SegueHighwayAlertViewController {
            let alertItem = (sender as! HighwayAlertItem)
            let destinationViewController = segue.destinationViewController as! HighwayAlertViewController
            destinationViewController.alertItem = alertItem
        }
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