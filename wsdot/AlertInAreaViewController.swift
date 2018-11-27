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
    
    var alerts = [HighwayAlertItem]()
    
    var trafficAlerts = [HighwayAlertItem]()
    var constructionAlerts = [HighwayAlertItem]()
    var specialEvents = [HighwayAlertItem]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for alert in alerts{
            if alert.eventCategory.lowercased() == "special event"{
                specialEvents.append(alert)
            } else if alert.headlineDesc.lowercased().contains("construction") || alert.eventCategory.lowercased().contains("construction") {
                constructionAlerts.append(alert)
            }else {
                trafficAlerts.append(alert)
            }
        }

        trafficAlerts = trafficAlerts.sorted(by: {$0.lastUpdatedTime.timeIntervalSince1970  > $1.lastUpdatedTime.timeIntervalSince1970})
        constructionAlerts = constructionAlerts.sorted(by: {$0.lastUpdatedTime.timeIntervalSince1970  > $1.lastUpdatedTime.timeIntervalSince1970})
        specialEvents = specialEvents.sorted(by: {$0.lastUpdatedTime.timeIntervalSince1970  > $1.lastUpdatedTime.timeIntervalSince1970})

        tableView.rowHeight = UITableView.automaticDimension
        
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch(section){
        case 0:
            return "Traffic Incidents" + (self.title != "Alert" && (trafficAlerts.count == 0) ? " - None Reported": "")
        case 1:
            return "Construction"  + (self.title != "Alert" && (constructionAlerts.count == 0) ? " - None Reported": "")
        case 2:
            return "Special Events"  + (self.title != "Alert" &&  (specialEvents.count == 0) ? " - None Reported": "")
        default:
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! LinkCell
        
        let htmlStyleString = "<style>body{font-family: '\(cell.linkLabel.font.fontName)'; font-size:\(cell.linkLabel.font.pointSize)px;}</style>"
        var htmlString = ""
        
        switch indexPath.section{
        case 0:
            cell.updateTime.text = TimeUtils.timeAgoSinceDate(date: trafficAlerts[indexPath.row].lastUpdatedTime, numericDates: false)
            htmlString = htmlStyleString + trafficAlerts[indexPath.row].headlineDesc
            break
        case 1:
            cell.updateTime.text = TimeUtils.timeAgoSinceDate(date: constructionAlerts[indexPath.row].lastUpdatedTime, numericDates: false)
            htmlString = htmlStyleString + constructionAlerts[indexPath.row].headlineDesc
            break
        case 2:
            cell.updateTime.text = TimeUtils.timeAgoSinceDate(date: specialEvents[indexPath.row].lastUpdatedTime, numericDates: false)
            htmlString = htmlStyleString + specialEvents[indexPath.row].headlineDesc
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
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch(indexPath.section){
        case 0:
            performSegue(withIdentifier: SegueHighwayAlertViewController, sender: trafficAlerts[indexPath.row])
            break
        case 1:
            performSegue(withIdentifier: SegueHighwayAlertViewController, sender: constructionAlerts[indexPath.row])
            break
        case 2:
            performSegue(withIdentifier: SegueHighwayAlertViewController, sender: specialEvents[indexPath.row])
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
    }
    
    // MARK: INDLinkLabelDelegate
    func linkLabel(_ label: INDLinkLabel, didLongPressLinkWithURL URL: Foundation.URL) {
        let activityController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    func linkLabel(_ label: INDLinkLabel, didTapLinkWithURL URL: Foundation.URL) {
        let svc = SFSafariViewController(url: URL, entersReaderIfAvailable: true)
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = ThemeManager.currentTheme().mainColor
        }
        self.present(svc, animated: true, completion: nil)
    }
    
    
}
