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
    
    var bridgeAlerts = [BridgeAlertItem]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Bridge Alerts"
        
        tableView.rowHeight = UITableView.automaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(BridgeAlertsViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        showOverlay(self.view)
        
        self.bridgeAlerts = BridgeAlertsStore.getAllBridgeAlerts()
        self.tableView.reloadData()
        
        self.refresh(false)
        
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
                            selfValue.bridgeAlerts = BridgeAlertsStore.getAllBridgeAlerts()
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
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.ferries, message: WSDOTErrorStrings.ferriesSchedule)
                        }
                    }
                }
            })
        }
    }

    @IBAction func refreshAction() {
        refresh(true)
    }
    
    
    // MARK: Table View Methods
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(bridgeAlerts.count)
        return bridgeAlerts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! BridgeCell

        cell.title.text = bridgeAlerts[indexPath.row].bridge
        cell.content.text = bridgeAlerts[indexPath.row].descText
        let updated = TimeUtils.timeAgoSinceDate(date: self.bridgeAlerts[indexPath.row].localCacheDate, numericDates: false)
        cell.updated.text = updated
        return cell
    }

}

