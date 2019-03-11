//
//  MyRouteCameras.swift
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

class MyRouteCamerasViewController: CameraClusterViewController {
    
    var route: MyRouteItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCamerasOnRoute(force: true)
    }
    
    func loadCamerasOnRoute(force: Bool){
        
        if route != nil {
            
            let serviceGroup = DispatchGroup();
            
            requestCamerasUpdate(force, serviceGroup: serviceGroup)
            
            serviceGroup.notify(queue: DispatchQueue.main) {
                
                if !self.route.foundCameras {
                    _ = MyRouteStore.getNearbyCameraIds(forRoute: self.route)
                }
                
                let nearbyCameras = CamerasStore.getCamerasByID(Array(self.route.cameraIds))
                
                self.cameraItems.removeAll()
                self.cameraItems.append(contentsOf: nearbyCameras)
                
                self.tableView.reloadData()
                
                if self.cameraItems.count == 0 {
                    self.tableView.isHidden = true
                } else {
                    self.tableView.isHidden = false
                }
            }
        }
    }
    
    fileprivate func requestCamerasUpdate(_ force: Bool, serviceGroup: DispatchGroup) {
        
        serviceGroup.enter()
        
        CamerasStore.updateCameras(force, completion: { error in
            if (error != nil) {
              
                serviceGroup.leave()
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
