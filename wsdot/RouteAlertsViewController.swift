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
        
        let htmlStyleLight =
        "<style>*{font-family:'-apple-system';font-size:\(cell.linkLabel.font.pointSize)px;color:black}h1{font-weight:bold}a{color: #007a5d}a strong{color: #007a5d}li{margin:10px 0}li:last-child{margin-bottom:25px}</style>"
        
        let htmlStyleDark =
        "<style>*{font-family:'-apple-system';font-size:\(cell.linkLabel.font.pointSize)px;color:white}h1{font-weight:bold}a{color: #007a5d}a strong{color: #007a5d}li{margin:10px 0}li:last-child{margin-bottom:25px}</style>"
        
        let AlertDescription = "<h1>" + alertItems[indexPath.row].alertFullTitle + "</h1>"
        let AlertFullText = alertItems[indexPath.row].alertFullText.replacingOccurrences(of: "</a><br></li>\n<li>", with: "</a></li>\n<li>", options: .regularExpression, range: nil)
        let htmlStringLight = htmlStyleLight + AlertDescription + AlertFullText
        let htmlStringDark = htmlStyleDark + AlertDescription + AlertFullText

        let attrStrLight = try! NSMutableAttributedString(
            data: htmlStringLight.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        let attrStrDark = try! NSMutableAttributedString(
            data: htmlStringDark.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        var alertPubDate: Date? = nil
        
        if let alertPubDateValue = try? TimeUtils.formatTimeStamp(alertItems[indexPath.row].publishDate, dateFormat: "yyyy-MM-dd hh:mm a") {
            alertPubDate = alertPubDateValue
        } else {
            alertPubDate = TimeUtils.parseJSONDateToNSDate(alertItems[indexPath.row].publishDate)
        }

        if let date = alertPubDate {
            cell.updateTime.text = TimeUtils.timeAgoSinceDate(date: date, numericDates: false)
        } else {
            cell.updateTime.text = "unavailable"
        }
        
        if self.traitCollection.userInterfaceStyle == .light {
            cell.linkLabel.attributedText = attrStrLight
            cell.linkLabel.linkHighlightColor = UIColor.lightGray
            cell.linkLabel.delegate = self
        }
        
        if self.traitCollection.userInterfaceStyle == .dark {
            cell.linkLabel.attributedText = attrStrDark
            cell.linkLabel.linkHighlightColor = UIColor.lightGray
            cell.linkLabel.delegate = self
        }
        
        return cell

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)

        fetchAlerts()
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

