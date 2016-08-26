//
//  MountainPassCamerasViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/25/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class MountainPassCamerasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    let camerasCellIdentifier = "PassCamerasCell"
    let SegueCamerasViewController = "CamerasViewController"
    
    let refreshControl = UIRefreshControl()
    var passItem : MountainPassItem = MountainPassItem()
    
    var cameras : [CameraItem] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mountainPassTabBarContoller = self.tabBarController as! MountainPassTabBarViewController
        passItem = mountainPassTabBarContoller.passItem
        
        print(passItem.cameras.count)
        
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
                        
                            var ids = [Int]()
                            for camera in selfValue.passItem.cameras{
                                ids.append(camera.cameraId)
                            }
                            selfValue.cameras = selfValue.filterCameras(CamerasStore.getCamerasByID(ids))
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
    

        return cameras
    }
    
    
}
