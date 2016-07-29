//
//  RouteCameras.swift
//  WSDOT
//
//  Created by Logan Sims on 7/28/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit

class RouteCamerasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{


    let camerasCellIdentifier = "TerminalCameras"

    let refreshControl = UIRefreshControl()

    var departingTerminalId = -1

    var cameras : [CameraItem] = []

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(RouteCamerasViewController.refresh(_:)), forControlEvents: .ValueChanged)
        refreshControl.attributedTitle = NSAttributedString.init(string: "loading cameras")
        tableView.addSubview(refreshControl)
        
        print(departingTerminalId)
        
        refreshControl.beginRefreshing()
        refresh(self.refreshControl)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {[weak self] in
            CamerasStore.getCameras("Ferries", completion:  { data, error in
                if (error == nil){
                    if let selfValue = self{
                        selfValue.cameras = selfValue.filterCameras(data)
                        dispatch_async(dispatch_get_main_queue()) {[weak self] in
                            if let selfValue = self{
                                selfValue.tableView.reloadData()
                                selfValue.refreshControl.endRefreshing()
                            }
                        }
                        
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            refreshControl.endRefreshing()
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                            
                        }
                    }
                }
            })
            
        }
    }
    
    // MARK: -
    // MARK: Table View Delegate & data source methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cameras.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(camerasCellIdentifier) as! CameraImageCustomCell
        
        if let url = NSURL(string: cameras[indexPath.row].url) {
            if let data = NSData(contentsOfURL: url) {
                cell.CameraImage.image = UIImage(data: data)
            }
        }
        
        return cell
    }
    
    // MARK: -
    // MARK: Helper functinos
    func filterCameras(cameras: [CameraItem]) -> [CameraItem] {
    
        var filteredCameras = [CameraItem]()
        for camera in cameras {
            
            let distance = LatLonUtils.haversine(
                (FerriesConsts.terminalMap[departingTerminalId]?.latitude)!,
                lonA: (FerriesConsts.terminalMap[departingTerminalId]?.longitude)!,
                latB: camera.latitude,
                lonB: camera.longitude)
            
            if (distance < 5280){
                filteredCameras.append(camera)
            }
        }
        return filteredCameras
    }
}
