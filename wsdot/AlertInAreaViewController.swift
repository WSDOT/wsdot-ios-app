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
import SafariServices

class AlertsInAreaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, INDLinkLabelDelegate {
    
    let cellIdentifier = "AlertCell"
    let SegueHighwayAlertViewController = "HighwayAlertViewController"
    let SegueTravelTimesViewController = "TravelTimesViewController"

    var alerts = [HighwayAlertItem]()
    var travelTimes = [TravelTimeItem]()

    var alertTypeAlerts = [HighwayAlertItem]()
    var bridgeAlerts = [HighwayAlertItem]()
    var constructionAlerts = [HighwayAlertItem]()
    var ferryAlerts = [HighwayAlertItem]()
    var incidentAlerts = [HighwayAlertItem]()
    var maintenanceAlerts = [HighwayAlertItem]()
    var policeActivityAlerts = [HighwayAlertItem]()
    var weatherAlerts = [HighwayAlertItem]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for alert in alerts{
            
            if alert.eventCategoryTypeDescription.lowercased() == "bridge"{
                bridgeAlerts.append(alert)
            }
            else if alert.eventCategoryTypeDescription.lowercased() == "construction"{
                constructionAlerts.append(alert)
            }
            else if alert.eventCategoryTypeDescription.lowercased() == "ferries"{
                ferryAlerts.append(alert)
            }
            else if alert.eventCategoryTypeDescription.lowercased() == "incident"{
                incidentAlerts.append(alert)
            }
            else if alert.eventCategoryTypeDescription.lowercased() == "maintenance"{
                    maintenanceAlerts.append(alert)
                }
            else if alert.eventCategoryTypeDescription.lowercased() == "police activity"{
                    policeActivityAlerts.append(alert)
                }
            else if alert.eventCategoryTypeDescription.lowercased() == "weather"{
                    weatherAlerts.append(alert)
                }
            else {
                alertTypeAlerts.append(alert)
            }
        }

        alertTypeAlerts = alertTypeAlerts.sorted(by: {$0.lastUpdatedTime.timeIntervalSince1970  > $1.lastUpdatedTime.timeIntervalSince1970})
        bridgeAlerts = bridgeAlerts.sorted(by: {$0.lastUpdatedTime.timeIntervalSince1970  > $1.lastUpdatedTime.timeIntervalSince1970})
        constructionAlerts = constructionAlerts.sorted(by: {$0.lastUpdatedTime.timeIntervalSince1970  > $1.lastUpdatedTime.timeIntervalSince1970})
        ferryAlerts = ferryAlerts.sorted(by: {$0.lastUpdatedTime.timeIntervalSince1970  > $1.lastUpdatedTime.timeIntervalSince1970})
        incidentAlerts = incidentAlerts.sorted(by: {$0.lastUpdatedTime.timeIntervalSince1970  > $1.lastUpdatedTime.timeIntervalSince1970})
        maintenanceAlerts = maintenanceAlerts.sorted(by: {$0.lastUpdatedTime.timeIntervalSince1970  > $1.lastUpdatedTime.timeIntervalSince1970})
        policeActivityAlerts = policeActivityAlerts.sorted(by: {$0.lastUpdatedTime.timeIntervalSince1970  > $1.lastUpdatedTime.timeIntervalSince1970})
        weatherAlerts = weatherAlerts.sorted(by: {$0.lastUpdatedTime.timeIntervalSince1970  > $1.lastUpdatedTime.timeIntervalSince1970})
        travelTimes = travelTimes.sorted(by: {$0.title < $1.title})
            .filter({$0.routeid != 36}).filter({$0.routeid != 37}).filter({$0.routeid != 68}).filter({$0.routeid != 69})

        tableView.rowHeight = UITableView.automaticDimension
        
        if self.alerts.count == 0 && self.travelTimes.count == 0 {
            self.tableView.isHidden = true

        } else {
            self.tableView.isHidden = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "AreaAlerts")
    }
    
    // MARK: Table View Data Source Methods
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch(section){
        
        case 0:
            if (alertTypeAlerts.count != 0) { return "Alert" } else { return nil }
        case 1:
            if (bridgeAlerts.count != 0) { return "Bridge" } else { return nil }
        case 2:
            if (constructionAlerts.count != 0) { return "Construction" } else { return nil }
        case 3:
            if (ferryAlerts.count != 0) { return "Ferries" } else { return nil }
        case 4:
            if (incidentAlerts.count != 0) { return "Incident" } else { return nil }
        case 5:
            if (maintenanceAlerts.count != 0) { return "Maintenance" } else { return nil }
        case 6:
            if (policeActivityAlerts.count != 0) { return "Police activity" } else { return nil }
        case 7:
            if (weatherAlerts.count != 0) { return "Weather" } else { return nil }
        case 8:
            if (travelTimes.count != 0) { return "Travel Times" } else { return nil }
        default:
            return nil
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch(section){
        case 0:
            return alertTypeAlerts.count
        case 1:
            return bridgeAlerts.count
        case 2:
            return constructionAlerts.count
        case 3:
            return ferryAlerts.count
        case 4:
            return incidentAlerts.count
        case 5:
            return maintenanceAlerts.count
        case 6:
            return policeActivityAlerts.count
        case 7:
            return weatherAlerts.count
        case 8:
            return travelTimes.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! LinkCell
        
        let htmlStyleString = "<style>body{font-family: '-apple-system'; font-size:\(cell.linkLabel.font.pointSize)px;}</style>"
        var htmlString = ""
        
        switch indexPath.section{
        case 0:
            cell.updateTime.text = TimeUtils.timeAgoSinceDate(date: alertTypeAlerts[indexPath.row].lastUpdatedTime, numericDates: false)
            htmlString = htmlStyleString + alertTypeAlerts[indexPath.row].headlineDesc
            break
        case 1:
            cell.updateTime.text = TimeUtils.timeAgoSinceDate(date: bridgeAlerts[indexPath.row].lastUpdatedTime, numericDates: false)
            htmlString = htmlStyleString + bridgeAlerts[indexPath.row].headlineDesc
            break
        case 2:
            cell.updateTime.text = TimeUtils.timeAgoSinceDate(date: constructionAlerts[indexPath.row].lastUpdatedTime, numericDates: false)
            htmlString = htmlStyleString + constructionAlerts[indexPath.row].headlineDesc
            break
        case 3:
            cell.updateTime.text = TimeUtils.timeAgoSinceDate(date: ferryAlerts[indexPath.row].lastUpdatedTime, numericDates: false)
            htmlString = htmlStyleString + ferryAlerts[indexPath.row].headlineDesc
            break
        case 4:
            cell.updateTime.text = TimeUtils.timeAgoSinceDate(date: incidentAlerts[indexPath.row].lastUpdatedTime, numericDates: false)
            htmlString = htmlStyleString + incidentAlerts[indexPath.row].headlineDesc
            break
        case 5:
            cell.updateTime.text = TimeUtils.timeAgoSinceDate(date: maintenanceAlerts[indexPath.row].lastUpdatedTime, numericDates: false)
            htmlString = htmlStyleString + maintenanceAlerts[indexPath.row].headlineDesc
            break
        case 6:
            cell.updateTime.text = TimeUtils.timeAgoSinceDate(date: policeActivityAlerts[indexPath.row].lastUpdatedTime, numericDates: false)
            htmlString = htmlStyleString + policeActivityAlerts[indexPath.row].headlineDesc
            break
        case 7:
            cell.updateTime.text = TimeUtils.timeAgoSinceDate(date: weatherAlerts[indexPath.row].lastUpdatedTime, numericDates: false)
            htmlString = htmlStyleString + weatherAlerts[indexPath.row].headlineDesc
            break
        case 8:
            cell.updateTime.text = "Routes: " + travelTimes[indexPath.row].viaText
            htmlString = htmlStyleString + travelTimes[indexPath.row].title
            break
        default:
            break
        }
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        cell.linkLabel.attributedText = attrStr
        cell.linkLabel.delegate = self
        
        if #available(iOS 13, *){
            cell.linkLabel.textColor = UIColor.label
        }
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch(indexPath.section){
        case 0:
            performSegue(withIdentifier: SegueHighwayAlertViewController, sender: alertTypeAlerts[indexPath.row])
            break
        case 1:
            performSegue(withIdentifier: SegueHighwayAlertViewController, sender: bridgeAlerts[indexPath.row])
            break
        case 2:
            performSegue(withIdentifier: SegueHighwayAlertViewController, sender: constructionAlerts[indexPath.row])
            break
        case 3:
            performSegue(withIdentifier: SegueHighwayAlertViewController, sender: ferryAlerts[indexPath.row])
            break
        case 4:
            performSegue(withIdentifier: SegueHighwayAlertViewController, sender: incidentAlerts[indexPath.row])
            break
        case 5:
            performSegue(withIdentifier: SegueHighwayAlertViewController, sender: maintenanceAlerts[indexPath.row])
            break
        case 6:
            performSegue(withIdentifier: SegueHighwayAlertViewController, sender: policeActivityAlerts[indexPath.row])
            break
        case 7:
            performSegue(withIdentifier: SegueHighwayAlertViewController, sender: weatherAlerts[indexPath.row])
            break
        case 8:
            performSegue(withIdentifier: SegueTravelTimesViewController, sender: travelTimes[indexPath.row])
            break
        default: break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Naviagtion
    // Get refrence to child VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueHighwayAlertViewController {
            let alertItem = (sender as! HighwayAlertItem)
            let destinationViewController = segue.destination as! HighwayAlertViewController
            destinationViewController.alertId = alertItem.alertId
        }
        
        if segue.identifier == SegueTravelTimesViewController {
            let alertItem = (sender as! TravelTimeItem)
            let destinationViewController = segue.destination as! TravelTimeAlertViewController
            destinationViewController.travelTimeId = alertItem.routeid
        }
    }
    
    // MARK: INDLinkLabelDelegate
    func linkLabel(_ label: INDLinkLabel, didLongPressLinkWithURL URL: Foundation.URL) {
        let activityController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    func linkLabel(_ label: INDLinkLabel, didTapLinkWithURL URL: Foundation.URL) {

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let svc = SFSafariViewController(url: URL, configuration: config)
        
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = ThemeManager.currentTheme().mainColor
        }
        self.present(svc, animated: true, completion: nil)
    }
    
    
}
