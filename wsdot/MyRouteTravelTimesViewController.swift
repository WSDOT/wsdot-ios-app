//
//  MyRouteTravelTimesViewController.swift
//  WSDOT
//
//  Copyright (c) 2019 Washington State Department of Transportation
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
                
                if !self.route.foundTravelTimes {
                    _ = MyRouteStore.getNearbyTravelTimeIds(forRoute: self.route)
                }
                
                let nearbyTimes = TravelTimesStore.getTravelTimesBy(ids: Array(self.route.travelTimeIds))
            
                self.travelTimeGroups.removeAll()
                self.travelTimeGroups.append(contentsOf: nearbyTimes)
                
                // sort by via text
                self.filtered = self.travelTimeGroups.sorted(by: {$0.routes[0].routeid < $1.routes[0].routeid })
                
                
                
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
        
        TravelTimesStore.updateTravelTimes(force, completion: { error in
            if (error != nil) {
                DispatchQueue.main.async { [weak self] in
                    if let selfValue = self{
                        selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion:   nil)
                    }
                }
            }
            serviceGroup.leave()
        })
    }
}
