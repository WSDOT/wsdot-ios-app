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

    var cameras : [CameraItem] = []

    @IBOutlet weak var tableView: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(RouteCamerasViewController.refresh(_:)), forControlEvents: .ValueChanged)
        refreshControl.attributedTitle = NSAttributedString.init(string: "loading cameras")
        tableView.addSubview(refreshControl)
        
        refreshControl.beginRefreshing()
        refresh(self.refreshControl)
    }
    
    
    func refresh(refreshControl: UIRefreshControl) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            CamerasStore.getCameras("Ferries", completion:  { data, error in
                if (error == nil){
                    if let selfValue = self{
                        selfValue.cameras = data
                        selfValue.tableView.reloadData()
                        print("Cameras Loaded")
                        refreshControl.endRefreshing()
                    }
                }else{
                    print("RouteDepartureViewContorller: Error getting cameras")
                    refreshControl.endRefreshing()
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
    
    
    
}
