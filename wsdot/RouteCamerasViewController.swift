//
//  RouteCameras.swift
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
        refresh(false)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Ferries/Schedules/Sailings/Cameras")
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
        
        // Add timestamp to help prevent caching
        let urlString = cameras[indexPath.row].url + "?" + String(NSDate().timeIntervalSince1970 / 60000)
        cell.CameraImage.sd_setImageWithURL(NSURL(string: urlString), placeholderImage: UIImage(named: "imagePlaceholder"), options: .RefreshCached)
        
        return cell
    }
    
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
                (FerriesConsts().terminalMap[departingTerminalId]?.latitude)!,
                lonA: (FerriesConsts().terminalMap[departingTerminalId]?.longitude)!,
                latB: camera.latitude,
                lonB: camera.longitude)
            
            if (distance < 5280){
                filteredCameras.append(camera)
            }
        }
        return filteredCameras
    }
}
