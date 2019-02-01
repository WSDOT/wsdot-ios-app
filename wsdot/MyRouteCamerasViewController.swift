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

class MyRouteCamerasViewController: UIViewController {
    
    var route: MyRouteItem!
    
    var cameras = [CameraItem]()
    
    override func viewDidLoad() {
        print(route.name)
        
        loadCamerasOnRoute(force: true)
        
    }
    
    func loadCamerasOnRoute(force: Bool){
        
        if route != nil {
            
            let serviceGroup = DispatchGroup();
            
            requestCamerasUpdate(force, serviceGroup: serviceGroup)
            
            serviceGroup.notify(queue: DispatchQueue.main) {
              
                print("done")
                
                //self.tableView.rowHeight = UITableView.automaticDimension
                //self.tableView.reloadData()
                
                //self.hideOverlayView()
              
                //self.refreshControl.endRefreshing()
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
                    
                    let nearbyCameras = CamerasStore.getCamerasByID(Array(route.cameraIds))
                
                    self.cameras.removeAll()
                
                    // copy alerts to unmanaged Realm object so we can access on main thread.
                    for camera in nearbyCameras {
                    
                        print(camera.roadName)
                        
                        let tempCamera = CameraItem()
                    
                        tempCamera.cameraId = camera.cameraId
                        tempCamera.latitude = camera.latitude
                        tempCamera.longitude = camera.longitude
                        tempCamera.direction = camera.direction
                        tempCamera.milepost = camera.milepost
                        tempCamera.roadName = camera.roadName
                        tempCamera.selected = camera.selected
                        tempCamera.title = camera.title
                        tempCamera.url = camera.url
                        tempCamera.video = camera.video
                    
                        self.cameras.append(tempCamera)
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
