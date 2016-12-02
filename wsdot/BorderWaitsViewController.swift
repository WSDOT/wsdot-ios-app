//
//  BorderWaitViewController.swift
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

import UIKit
import GoogleMobileAds

class BorderWaitsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate{
    
    let cellIdentifier = "borderwaitcell"
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var segmentedControlView: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var displayedWaits = [BorderWaitItem]()
    var northboundWaits = [BorderWaitItem]()
    var southboundWaits = [BorderWaitItem]()
    
    let i5Icon = UIImage(named:"icListI5")
    let sr9Icon = UIImage(named: "icListSR9")
    let sr539Icon = UIImage(named: "icListSR539")
    let sr543Icon = UIImage(named: "icListSR543")
    let us97Icon = UIImage(named: "icListUS97")
    
    let bc11Icon = UIImage(named: "icListBC11")
    let bc13Icon = UIImage(named: "icListBC13")
    let bc15Icon = UIImage(named: "icListBC15")
    let bc97Icon = UIImage(named: "icListBC97")
    let bc99Icon = UIImage(named: "icListBC99")
    
    let refreshControl = UIRefreshControl()
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayedWaits = northboundWaits

        // refresh controller
        refreshControl.addTarget(self, action: #selector(BorderWaitsViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        showOverlay(self.view)
        
        self.northboundWaits = BorderWaitStore.getNorthboundWaits()
        self.southboundWaits = BorderWaitStore.getSouthboundWaits()
        self.tableView.reloadData()
        
        refresh(false)
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.wsdot_ad_string
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        bannerView.isAccessibilityElement = true
        bannerView.accessibilityLabel = "advertisement banner."
    }
    
    func refreshAction(_ refreshControl: UIRefreshControl) {
        refresh(true)
    }
    
    func refresh(_ force: Bool){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            BorderWaitStore.updateWaits(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.northboundWaits = BorderWaitStore.getNorthboundWaits()
                            selfValue.southboundWaits = BorderWaitStore.getSouthboundWaits()
                            if (selfValue.segmentedControlView.selectedSegmentIndex == 0){
                                selfValue.displayedWaits = selfValue.northboundWaits
                            } else {
                                selfValue.displayedWaits = selfValue.southboundWaits
                            }
                            selfValue.tableView.reloadData()
                            selfValue.hideOverlayView()
                            selfValue.refreshControl.endRefreshing()
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.hideOverlayView()
                            selfValue.refreshControl.endRefreshing()
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    func showOverlay(_ view: UIView) {
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor.gray
        
        if self.splitViewController!.isCollapsed {
            activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        } else {
            activityIndicator.center = CGPoint(x: view.center.x - self.splitViewController!.viewControllers[0].view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        }
        
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    func hideOverlayView(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedWaits.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! BorderWaitCell
        
        let wait = displayedWaits[indexPath.row]
        
        cell.nameLabel.text = wait.name + " (" + wait.lane + ")"
        
        do {
            let updated = try TimeUtils.timeAgoSinceDate(TimeUtils.formatTimeStamp(wait.updated), numericDates: false)
            cell.updatedLabel.text = updated
        } catch TimeUtils.TimeUtilsError.invalidTimeString {
            cell.updatedLabel.text = "N/A"
        } catch {
            cell.updatedLabel.text = "N/A"
        }
        
        if wait.waitTime == -1 {
            cell.waitTimeLabel.text = "N/A"
        }else if wait.waitTime < 5 {
            cell.waitTimeLabel.text = "< 5 min"
        }else{
            cell.waitTimeLabel.text = String(wait.waitTime) + " min"
        }
        
        cell.RouteImage.image = getIcon(wait.route)
        
        return cell
    }
    
    func getIcon(_ route: Int) -> UIImage?{
        
        if (segmentedControlView.selectedSegmentIndex == 0){
            switch(route){
            case 5: return i5Icon
            case 9: return sr9Icon
            case 97: return us97Icon
            case 539: return sr539Icon
            case 543: return sr543Icon
            default: return nil
            }
        }else{
            switch(route){
            case 5: return bc99Icon
            case 9: return bc11Icon
            case 539: return bc13Icon
            case 543: return bc15Icon
            default: return nil
            }
        }
    }
    
    // Remove and add hairline for nav bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Border Waits")
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, for: .default)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex){
        case 0:
            displayedWaits = northboundWaits
            tableView.reloadData()
            break
        case 1:
            displayedWaits = southboundWaits
            tableView.reloadData()
            break
        default:
            break
        }
    }
}
