//
//  BridgeAlertsViewController.swift
//  WSDOT
//
import Foundation
import UIKit
import SafariServices

class BridgeAlertsViewController: RefreshViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier = "BridgeCell"
    let SegueHighwayAlertViewController = "BridgeAlertViewController"
    
    var overlayView = UIView()
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
        
    var topicItemsMap = [String: [BridgeAlertItem]]()
    var topicCategoriesMap = [Int: String]()

        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Bridge Alerts"
        
        tableView.rowHeight = UITableView.automaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(BridgeAlertsViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        showOverlay(self.view)

        self.tableView.reloadData()
        self.refresh(true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "BridgeAlerts")
    }
    
    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        refresh(true)
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
                            
                            if (selfValue.topicItemsMap["Hood Canal"] == nil)
                            {
                                selfValue.topicItemsMap["Hood Canal"] = [BridgeAlertItem()]
                            }
                            
                            if (selfValue.topicItemsMap["Interstate Bridge"] == nil)
                            {
                                selfValue.topicItemsMap["Interstate Bridge"] = [BridgeAlertItem()]
                            }
                            
                            print(selfValue.topicItemsMap)
                            selfValue.topicCategoriesMap = selfValue.getCategoriesMap(topicItemsMap: selfValue.topicItemsMap)
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
        let updated = TimeUtils.timeAgoSinceDate(date: topicItem.localCacheDate, numericDates: false)
        
        if let openingTime = topicItem.openingTime {
            cell.subContent.text = "Opening Time: " + TimeUtils.formatTime(openingTime, format: "MMMM dd, YYYY h:mm a")
            
        } else {
            cell.subContent.text = ""
            
        }
        cell.updated.text = "Last Updated: " + updated
        
        if ((topicItem.alertId) != 0) {
            cell.title.text = topicItem.bridge
            cell.content.text = topicItem.descText
            return cell
            
        } else {
            cell.title.text = ""
            cell.content.text = "No Alerts Reported"
            cell.subContent.text = ""
            return cell
            
        }
        
    }
    
}
