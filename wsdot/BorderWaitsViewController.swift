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

class BorderWaitsViewController: RefreshViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    let cellIdentifier = "borderwaitcell"
    
    @IBOutlet weak var bannerView: DFPBannerView!
    @IBOutlet weak var segmentedControlView: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var displayedWaits = [BorderWaitItem]()
    var northboundWaits = [BorderWaitItem]()
    var southboundWaits = [BorderWaitItem]()
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayedWaits = northboundWaits

        // refresh controller
        refreshControl.addTarget(self, action: #selector(BorderWaitsViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        showOverlay(self.view)
        
        // remove southbound wait times until we can get more accurate times.
        self.northboundWaits = BorderWaitStore.getNorthboundWaits()
        //self.southboundWaits = BorderWaitStore.getSouthboundWaits()
        self.tableView.reloadData()
        
        refresh(false)
        tableView.rowHeight = UITableView.automaticDimension
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.getAdId()
        bannerView.rootViewController = self
        let request = DFPRequest()
        request.customTargeting = ["wsdotapp":"border"]
        
        bannerView.load(request)
        bannerView.delegate = self
        
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isAccessibilityElement = true
        bannerView.accessibilityLabel = "advertisement banner."
    }
    
    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
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
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.borderWaits, message: WSDOTErrorStrings.borderWaits)
                        }
                    }
                }
            })
        }
    }

    
    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedWaits.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! BorderWaitCell
        
        let wait = displayedWaits[indexPath.row]
        
        cell.nameLabel.text = wait.name + " (" + wait.lane + ")"
        
        do {
            let updated = try TimeUtils.timeAgoSinceDate(date: TimeUtils.formatTimeStamp(wait.updated), numericDates: false)
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
        
        // set up favorite button
        cell.favoriteButton.setImage(wait.selected ? UIImage(named: "icStarSmallFilled") : UIImage(named: "icStarSmall"), for: .normal)
        cell.favoriteButton.tintColor = ThemeManager.currentTheme().darkColor

        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(favoriteAction(_:)), for: .touchUpInside)
        
        cell.RouteImage.image = UIHelpers.getRouteIconFor(borderWait: wait)
        
        return cell
    }
    

    
    // Remove and add hairline for nav bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, for: .default)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "BorderWaitsNorthbound")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex){
        case 0:
            MyAnalytics.screenView(screenName: "BorderWaitsNorthbound")
            displayedWaits = northboundWaits
            tableView.reloadData()
            break
        case 1:
            MyAnalytics.screenView(screenName: "BorderWaitsSouthBound")
            displayedWaits = southboundWaits
            tableView.reloadData()
            break
        default:
            break
        }
    }
    
    // MARK: Favorite action
    @objc func favoriteAction(_ sender: UIButton) {
        let index = sender.tag
        let wait = displayedWaits[index]
        
        if (wait.selected){
            BorderWaitStore.updateFavorite(wait, newValue: false)
            sender.setImage(UIImage(named: "icStarSmall"), for: .normal)
        }else {
            BorderWaitStore.updateFavorite(wait, newValue: true)
            sender.setImage(UIImage(named: "icStarSmallFilled"), for: .normal)
        }
    }
    
}
