//
//  MountainPassCamerasViewController.swift
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

import Foundation
import UIKit
import GoogleMobileAds

class MountainPassCamerasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    let camerasCellIdentifier = "PassCamerasCell"
    let SegueCamerasViewController = "CamerasViewController"
    
    let refreshControl = UIRefreshControl()
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
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
        showOverlay(self.view)
        refresh(false)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Mountain Passes/Cameras")
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
                            selfValue.cameras = CamerasStore.getCamerasByID(ids)
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                        }
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    func showOverlay(view: UIView) {
        
        overlayView.frame = CGRectMake(0, 0, 80, 80)
        overlayView.center = CGPointMake(view.center.x, view.center.y - self.navigationController!.navigationBar.frame.size.height)
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.alpha = 0.7
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRectMake(0, 0, 40, 40)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = CGPointMake(overlayView.bounds.width / 2, overlayView.bounds.height / 2)
        
        overlayView.addSubview(activityIndicator)
        view.addSubview(overlayView)
        
        activityIndicator.startAnimating()
    }
    
    func hideOverlayView(){
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
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
}
