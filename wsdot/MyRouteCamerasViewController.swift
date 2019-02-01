//
//  MyRouteCameras.swift
//  WSDOT
//
//  Created by Logan Sims on 2/1/19.
//  Copyright © 2019 WSDOT. All rights reserved.
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
        
        let routeRef = ThreadSafeReference(to: self.route!)
        
        CamerasStore.updateCameras(force, completion: { error in
            if (error == nil){
                
                let routeItem = try! Realm().resolve(routeRef)
                
                if let route = routeItem {
                    
                    if !route.foundCameras {
                        _ = MyRouteStore.getNearbyCameraIds(forRoute: route)
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
