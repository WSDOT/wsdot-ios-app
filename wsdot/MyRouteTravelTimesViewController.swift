//
//  MyRouteTravelTimesViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 2/4/19.
//  Copyright © 2019 WSDOT. All rights reserved.
//

import UIKit
import RealmSwift
import SafariServices

class MyRouteTravelTimesViewController: TravelTimesViewController {
    
    var route: MyRouteItem!
    
    override func viewDidLoad() {
    
        // refresh controller
        refreshControl.addTarget(self, action: #selector(MyRouteTravelTimesViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        showOverlay(self.view)
        
        tableView.rowHeight = UITableView.automaticDimension
        
        loadTravelTimesOnRoute(force: true)
    
    }
    
    @objc override func refreshAction(_ refreshControl: UIRefreshControl) {
        loadTravelTimesOnRoute(force: true)
    }
    
    func loadTravelTimesOnRoute(force: Bool) {
        
        if route != nil {
            
            let serviceGroup = DispatchGroup();
            
            requestTravelTimesUpdate(force, serviceGroup: serviceGroup)
            
            serviceGroup.notify(queue: DispatchQueue.main) {
                
                let nearbyTimes = TravelTimesStore.getTravelTimesBy(ids: Array(self.route.travelTimeIds))
            
                self.travelTimeGroups.removeAll()
                self.travelTimeGroups.append(contentsOf: nearbyTimes)
                self.filtered = self.travelTimeGroups
                self.refreshControl.endRefreshing()
                self.hideOverlayView()
                self.tableView.reloadData()
                
                if self.filtered.count == 0 {
                    self.tableView.isHidden = true
                } else {
                    self.tableView.isHidden = false
                }
                
            }
        }
    }
    
    
    fileprivate func requestTravelTimesUpdate(_ force: Bool, serviceGroup: DispatchGroup) {
        
        serviceGroup.enter()
        
        let routeRef = ThreadSafeReference(to: self.route!)
        
        TravelTimesStore.updateTravelTimes(force, completion: { error in
            if (error == nil){
                
                let routeItem = try! Realm().resolve(routeRef)
                
                if let route = routeItem {
                    
                    if !route.foundTravelTimes {
                        _ = MyRouteStore.getNearbyTravelTimeIds(forRoute: route)
                    }
                    
                    serviceGroup.leave()
                } else {
                    serviceGroup.leave()
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion:   nil)
                        }
                    }
                }
            }
        })
    }
    
}
