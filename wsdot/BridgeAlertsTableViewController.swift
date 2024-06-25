//
//  BridgeAlertsTableViewController.swift
//  WSDOT
//
//  Copyright (c) 2022 Washington State Department of Transportation
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

class BridgeAlertsTableViewController: RefreshViewController, INDLinkLabelDelegate, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "BridgeCell"
    var overlayView = UIView()
    let refreshControl = UIRefreshControl()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    fileprivate weak var timer: Timer?

    var topicItemsMap = [String: [BridgeAlertItem]]()
    var topicCategoriesMap = [Int: String]()

    var window = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Bridge Alerts"

        tableView.rowHeight = UITableView.automaticDimension

        // refresh controller
        refreshControl.addTarget(self, action: #selector(BridgeAlertsTableViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)

        showOverlay(self.view)

        self.tableView.reloadData()
        self.refresh(true)
        self.activityIndicatorView.isHidden = true

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "BridgeAlerts")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh(true)
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(CachesStore.bridgeUpdateTime), target: self, selector: #selector(BridgeAlertsTableViewController.refreshAction(_:)), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
    }
    
    // check traffic alert data cache & set timer
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        refresh(true)

    }
    
    // invalidated timer
    @objc func applicationDidEnterBackground(notification: NSNotification) {
        timer?.invalidate()
    }
    
    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        refresh(true)
    }
    
    @IBAction func refreshPressed(_ sender: UIBarButtonItem) {
        MyAnalytics.event(category: "Bridge Alerts", action: "UIAction", label: "Refresh")
        
        showOverlay(self.view)
        self.refresh(true)
        self.activityIndicatorView.isHidden = true

        
    }

    func refresh(_ force: Bool){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            BridgeAlertsStore.updateBridgeAlerts(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{

                            BridgeAlertsStore.flushOldData()
                            selfValue.topicItemsMap = BridgeAlertsStore.getAllBridgeAlerts()

                            if (selfValue.topicItemsMap["1st Avenue South Bridge"] == nil)
                            {
                                selfValue.topicItemsMap["1st Avenue South Bridge"] = [BridgeAlertItem()]
                            }

                            if (selfValue.topicItemsMap["Hood Canal Bridge"] == nil)
                            {
                                selfValue.topicItemsMap["Hood Canal Bridge"] = [BridgeAlertItem()]
                            }

                            if (selfValue.topicItemsMap["Interstate Bridge"] == nil)
                            {
                                selfValue.topicItemsMap["Interstate Bridge"] = [BridgeAlertItem()]
                            }

                            selfValue.topicCategoriesMap = selfValue.getCategoriesMap(topicItemsMap: selfValue.topicItemsMap)
                            selfValue.topicItemsMap["1st Avenue South Bridge"]?.sort(by: {$0.lastUpdatedTime.timeIntervalSince1970 > $1.lastUpdatedTime.timeIntervalSince1970})
                            selfValue.topicItemsMap["Hood Canal Bridge"]?.sort(by: {$0.lastUpdatedTime.timeIntervalSince1970 > $1.lastUpdatedTime.timeIntervalSince1970})
                            selfValue.topicItemsMap["Interstate Bridge"]?.sort(by: {$0.lastUpdatedTime.timeIntervalSince1970 > $1.lastUpdatedTime.timeIntervalSince1970})

                            selfValue.tableView.reloadData()
                            selfValue.hideOverlayView()
                            selfValue.refreshControl.endRefreshing()
                            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: selfValue.tableView)

                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.hideOverlayView()
                            selfValue.refreshControl.endRefreshing()
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.bridges, message: WSDOTErrorStrings.bridgeAlerts)
                        }
                    }
                }
            })
        }
    }

    @IBAction func refreshAction() {
        refresh(true)
    }

    func getCategoriesMap(topicItemsMap: [String:[BridgeAlertItem]]) -> [Int: String]{

        let categories = Array(topicItemsMap.keys).sorted()
        var topicCategoriesMap = [Int: String]()

        var i = 0
        for category in categories {
            topicCategoriesMap[i] = category
            i += 1
        }
        return topicCategoriesMap
    }


    // MARK: Table View Methods
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }


    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {

        return topicCategoriesMap.keys.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return topicCategoriesMap[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return topicItemsMap[topicCategoriesMap[section]!]!.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! BridgeCell
        let topicItem = topicItemsMap[topicCategoriesMap[indexPath.section]!]![indexPath.row]
        let updated = TimeUtils.timeAgoSinceDate(date: topicItem.lastUpdatedTime, numericDates: false)
        
        cell.content.delegate = self
        cell.updated.isHidden = false

        // Check for valid alert ID
        if ((topicItem.alertId) != 0) {
            cell.title.text = topicItem.bridge
            let htmlStyleString = "<style>body{font: -apple-system-body}a{text-decoration: none}</style>"
            let htmlString = htmlStyleString + topicItem.descText
            let attrStr = try! NSMutableAttributedString(
                data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
                options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil)
            
            cell.content.attributedText = attrStr
            cell.updated.text = updated

            if #available(iOS 13.0, *) {
                cell.content.textColor = UIColor.label
            }
            
            if let openingTime = topicItem.openingTime {
                cell.subContent.text = "Opening Time: " + TimeUtils.formatTime(openingTime, format: "MMMM dd, YYYY h:mm a")
                cell.subContent.isHidden = false
            }
            else {
                cell.subContent.isHidden = true
            }
            
            cell.isUserInteractionEnabled = true
            cell.accessoryType = .disclosureIndicator

            return cell

        } else {
            cell.title.text = ""
            cell.content.text = "No Alerts Reported"
            cell.subContent.text = ""
            cell.subContent.isHidden = false
            cell.updated.isHidden = true
            cell.isUserInteractionEnabled = false
            cell.accessoryType = .none

            return cell

        }

    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let topicItem = topicItemsMap[topicCategoriesMap[indexPath.section]!]![indexPath.row]
        launchBridgeAlertDetailsScreen(alertId: topicItem.alertId, latitude: topicItem.latitude, longitude: topicItem.longitude)

                tableView.deselectRow(at: indexPath, animated: true)

    }

    func launchBridgeAlertDetailsScreen(alertId: Int, latitude: Double, longitude: Double){

        let bridgeAlertsStoryboard: UIStoryboard = UIStoryboard(name: "BridgeAlerts", bundle: nil)

        // Set up nav and vc stack
        let bridgesNav = bridgeAlertsStoryboard.instantiateViewController(withIdentifier: "BridgesNav") as! UINavigationController
        let bridgeAlertTableView = bridgeAlertsStoryboard.instantiateViewController(withIdentifier: "BridgeAlertsViewController") as! BridgeAlertsTableViewController

        let bridgeAlertDetailView = bridgeAlertsStoryboard.instantiateViewController(withIdentifier: "BridgeAlertDetailViewController") as! BridgeAlertDetailViewController

        bridgeAlertDetailView.alertId = alertId
        bridgeAlertDetailView.fromPush = true
        bridgeAlertDetailView.pushLat = latitude
        bridgeAlertDetailView.pushLong = longitude

        // assign vc stack to new nav controller
        if UIDevice.current.userInterfaceIdiom == .pad {
            bridgesNav.setViewControllers([bridgeAlertTableView, bridgeAlertDetailView], animated: false)

        } else {
            bridgesNav.setViewControllers([bridgeAlertDetailView], animated: false)

        }

        setNavController(newNavigationController: bridgesNav)

    }

    func setNavController(newNavigationController: UINavigationController){
        // get the main split view, check how VCs are currently displayed

        let rootViewController = UIApplication.shared.windows.first!.rootViewController as! UISplitViewController
        if (rootViewController.isCollapsed) {
            // Only one vc displayed, pop current stack and assign new vc stack
            let nav = rootViewController.viewControllers[0] as! UINavigationController
//            nav.popToRootViewController(animated: false)
            nav.pushViewController(newNavigationController, animated: true)

            print("1")

        } else {
            // Master/Detail displayed, swap out the current detail view with the new stack of view controllers.
            newNavigationController.viewControllers[0].navigationItem.leftBarButtonItem = rootViewController.displayModeButtonItem
            newNavigationController.viewControllers[0].navigationItem.leftItemsSupplementBackButton = true
            rootViewController.showDetailViewController(newNavigationController, sender: self)

            print("2")

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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
      super.traitCollectionDidChange(previousTraitCollection)
      if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
          
          if #available(iOS 14.0, *) {
              let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! BridgeCell
              cell.title.adjustsFontForContentSizeCategory = true
              cell.content.adjustsFontForContentSizeCategory = true
              cell.subContent.adjustsFontForContentSizeCategory = true
              cell.updated.adjustsFontForContentSizeCategory = true

          }
      }
    }

}
