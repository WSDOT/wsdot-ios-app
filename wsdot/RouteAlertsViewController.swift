//
//  RouteAlertsViewController.swift
//  WSDOT
//
//  Copyright (c) 2018 Washington State Department of Transportation
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
import RealmSwift
import SafariServices

class RouteAlertsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, INDLinkLabelDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    let cellIdentifier = "RouteAlerts"

    var routeId = 0
    var alertItems = [FerryAlertItem]()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        
        tableView.rowHeight = UITableView.automaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(RouteAlertsViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        fetchAlerts()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "FerryBulletins")
    }
    
    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
       // showConnectionAlert = true
        fetchAlerts()
    }
    
    func fetchAlerts() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            FerryRealmStore.updateRouteSchedules(false, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self {
                            
                            if let routeItem = FerryRealmStore.findSchedule(withId: selfValue.routeId) {
                                selfValue.title = "\(routeItem.routeDescription) Alerts"
                                selfValue.alertItems = routeItem.routeAlerts.sorted(by: {$0.publishDate > $1.publishDate})
                                selfValue.tableView.reloadData()
                            }
                            
                            if selfValue.alertItems.count == 0 {
                                selfValue.title = "No Alerts"
                            }
                            
                            selfValue.activityIndicator.stopAnimating()
                            selfValue.activityIndicator.isHidden = true
                            selfValue.refreshControl.endRefreshing()
                            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: selfValue.tableView)
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.ferries)
                        }
                    }
                }
            })
        }
    }
    
    
    // MARK: tableview
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! LinkCell
        
        let htmlStyleString = "<style>body{font-family: '\(cell.linkLabel.font.familyName)'; font-size:\(cell.linkLabel.font.pointSize)px;}</style>"
        
        let htmlString = htmlStyleString + alertItems[indexPath.row].alertFullText
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        var alertPubDate: Date? = nil
        
        if let alertPubDateValue = try? TimeUtils.formatTimeStamp(alertItems[indexPath.row].publishDate, dateFormat: "yyyy-MM-dd HH:mm aa") {
            alertPubDate = alertPubDateValue
        } else {
            alertPubDate = TimeUtils.parseJSONDateToNSDate(alertItems[indexPath.row].publishDate)
        }

        if let date = alertPubDate {
            cell.updateTime.text = TimeUtils.timeAgoSinceDate(date: date, numericDates: false)
        } else {
            cell.updateTime.text = "unavailable"
        }

        cell.linkLabel.attributedText = attrStr
        cell.linkLabel.delegate = self
        
        if #available(iOS 13, *) {
            cell.linkLabel.textColor = UIColor.label
        }
        
        return cell
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

