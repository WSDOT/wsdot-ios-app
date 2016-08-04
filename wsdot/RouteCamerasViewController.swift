//
//  RouteCameras.swift
//  WSDOT
//
//  Created by Logan Sims on 7/28/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit
import SDWebImage

class RouteCamerasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    let camerasCellIdentifier = "TerminalCameras"
    let SegueCamerasViewController = "CamerasViewController"

    let refreshControl = UIRefreshControl()

    var departingTerminalId = -1

    var cameras : [CameraItem] = []

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(RouteCamerasViewController.refreshAction(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height)
        refreshControl.beginRefreshing()
        refresh(false)
        
    }
    
    func refreshAction(refreshControl: UIRefreshControl) {
        refresh(true)
    }
    
    func refresh(force: Bool) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {[weak self] in
            CamerasStore.updateCameras(force, completion: { error in
                if (error == nil){
                    dispatch_async(dispatch_get_main_queue()) {[weak self] in
                        if let selfValue = self{
                            selfValue.cameras = selfValue.filterCameras(CamerasStore.getCamerasByRoadName("Ferries"))
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                        }
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    // MARK: -
    // MARK: Table View Data source methods
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
        
        cell.CameraImage.sd_setImageWithURL(NSURL(string: cameras[indexPath.row].url), placeholderImage: UIImage(named: "imagePlaceholder"), options: .RefreshCached)
        
        return cell
    }
    
    // MARK: -
    // MARK: Table View Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Perform Segue
        performSegueWithIdentifier(SegueCamerasViewController, sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueCamerasViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let cameraItem = self.cameras[indexPath.row] as CameraItem
                let destinationViewController = segue.destinationViewController as! CameraViewController
                destinationViewController.cameraItem = cameraItem
            }
        }
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
