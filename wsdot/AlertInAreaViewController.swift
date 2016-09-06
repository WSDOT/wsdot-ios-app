//
//  AlertInAreaViewController.swift
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

class AlertsInAreaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, INDLinkLabelDelegate {
    
    let cellIdentifier = "AlertCell"
    let SegueHighwayAlertViewController = "HighwayAlertViewController"
    
    var alerts = [HighwayAlertItem]()
    
    var trafficAlerts = [HighwayAlertItem]()
    var constructionAlerts = [HighwayAlertItem]()
    var specialEvents = [HighwayAlertItem]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Traffic Map/Area Alerts")
    }
    
    // MARK: Table View Data Source Methods
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch(section){
        case 0:
            return "Traffic Alerts" + (trafficAlerts.count == 0 ? " - None Reported": "")
        case 1:
            return "Construction"  + (constructionAlerts.count == 0 ? " - None Reported": "")
        case 2:
            return "Special Events"  + (specialEvents.count == 0 ? " - None Reported": "")
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
            cell.updateTime.text = TimeUtils.timeAgoSinceDate(trafficAlerts[indexPath.row].lastUpdatedTime, numericDates: false)
            htmlString = htmlStyleString + trafficAlerts[indexPath.row].headlineDesc
            break
        case 1:
            cell.updateTime.text = TimeUtils.timeAgoSinceDate(constructionAlerts[indexPath.row].lastUpdatedTime, numericDates: false)
            htmlString = htmlStyleString + constructionAlerts[indexPath.row].headlineDesc
            break
        case 2:
            cell.updateTime.text = TimeUtils.timeAgoSinceDate(specialEvents[indexPath.row].lastUpdatedTime, numericDates: false)
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
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch(indexPath.section){
        case 0:
            performSegueWithIdentifier(SegueHighwayAlertViewController, sender: trafficAlerts[indexPath.row])
            break
        case 1:
            performSegueWithIdentifier(SegueHighwayAlertViewController, sender: constructionAlerts[indexPath.row])
            break
        case 2:
            performSegueWithIdentifier(SegueHighwayAlertViewController, sender: specialEvents[indexPath.row])
            break
        default: break
        }
        
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