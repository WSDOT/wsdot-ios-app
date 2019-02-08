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
