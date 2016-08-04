//
//  FavoritesViewController.swift
//  wsdot
//
//  Created by Logan Sims on 6/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let TITLE = "Favorites"
    
    let ferriesCellIdentifier = "FerriesFavoriteCell"
    let cameraCellIdentifier = "CameraFavoriteCell"
    
    let segueRouteDeparturesViewController = "FavoriteSailingsViewController"
    let segueCameraViewController = "FavoriteCameraViewController"
    
    @IBOutlet weak var favoritesTable: UITableView!
    
    var favoriteRoutes = [FerryScheduleItem]()
    var favoriteCameras = [CameraItem]()
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = TITLE
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(FavoritesViewController.loadFavorites), forControlEvents: .ValueChanged)
        favoritesTable.addSubview(refreshControl)
        
        favoritesTable.rowHeight = UITableViewAutomaticDimension
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadFavorites()
    }
    
    override func viewDidDisappear(animated: Bool) {
        if (self.editing){
            self.setEditing(false, animated: false)
        }
        
        if (self.favoritesTable.editing){
            self.favoritesTable.setEditing(false, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Initialize Tab Bar Item
        tabBarItem = UITabBarItem(title: TITLE, image: UIImage(named: "ic-star"), tag: 1)
    }
    
    @objc private func loadFavorites(){
        
        let serviceGroup = dispatch_group_create();
        
        self.requestFavoriteFerries(serviceGroup)
        self.requestFavoriteCameras(serviceGroup)
        
        dispatch_group_notify(serviceGroup, dispatch_get_main_queue()) { // 2
            self.favoritesTable.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    private func requestFavoriteFerries(serviceGroup: dispatch_group_t){
        dispatch_group_enter(serviceGroup)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            FerryRealmStore.updateRouteSchedules(true, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        dispatch_group_leave(serviceGroup)
                        if let selfValue = self{
                            selfValue.favoriteRoutes = FerryRealmStore.findFavoriteSchedules()
                        }
                    }
                } else {
                    dispatch_group_leave(serviceGroup)
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    private func requestFavoriteCameras(serviceGroup: dispatch_group_t){
        dispatch_group_enter(serviceGroup)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
        CamerasStore.getCameras(nil, favorites: true, completion: { data, error in
                if let validData = data {
                    if let selfValue = self{
                        selfValue.favoriteCameras = validData
                    }
                    dispatch_group_leave(serviceGroup)
                } else {
                    dispatch_group_leave(serviceGroup)
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
                
            })
        }
    }
    
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch(section){
        case 0:
            if self.favoriteRoutes.count > 0 {
                return "Ferry Schedules"
            }
            return nil
        case 1:
            if self.favoriteCameras.count > 0 {
                return "Cameras"
            }
            return nil
        default:
            return nil
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch(section){
            
        case 0:
            return favoriteRoutes.count
        case 1:
            return favoriteCameras.count
        default:
            return 0
        }
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch(indexPath.section){
            
        case 0:
            let ferryCell = tableView.dequeueReusableCellWithIdentifier(ferriesCellIdentifier) as! RoutesCustomCell
            
            ferryCell.title.text = favoriteRoutes[indexPath.row].routeDescription
            
            if self.favoriteRoutes[indexPath.row].crossingTime != nil {
                ferryCell.subTitleOne.hidden = false
                ferryCell.subTitleOne.text = "Crossing time: ~ " + self.favoriteRoutes[indexPath.row].crossingTime! + " min"
            } else {
                ferryCell.subTitleOne.hidden = true
            }
            
            ferryCell.subTitleTwo.text = TimeUtils.timeAgoSinceDate(self.favoriteRoutes[indexPath.row].cacheDate, numericDates: true)
            
            return ferryCell
            
        case 1:
            let cameraCell = tableView.dequeueReusableCellWithIdentifier(cameraCellIdentifier, forIndexPath: indexPath)
            cameraCell.textLabel?.text = favoriteCameras[indexPath.row].title
            return cameraCell
            
        default:
            return tableView.dequeueReusableCellWithIdentifier("", forIndexPath: indexPath)

        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.favoritesTable.setEditing(editing, animated: animated)
    }

    // support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    // support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            
            switch (indexPath.section) {
            case 0:
                FerryRealmStore.updateFavorite(favoriteRoutes[indexPath.row], newValue: false)
                favoriteRoutes.removeAtIndex(indexPath.row)
            case 1:
                CamerasStore.updateFavorite(favoriteCameras[indexPath.row].cameraId, newValue: false)
                favoriteCameras.removeAtIndex(indexPath.row)
                break
            default:
                break
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    
    // MARK: - Navigation
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (indexPath.section){
            
        case 0:
            performSegueWithIdentifier(segueRouteDeparturesViewController, sender: nil)
            break
        case 1:
            performSegueWithIdentifier(segueCameraViewController, sender: nil)
            break
        default:
            break
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueRouteDeparturesViewController {
            if let indexPath = favoritesTable.indexPathForSelectedRow {
                let routeItem = self.favoriteRoutes[indexPath.row] as FerryScheduleItem
                let destinationViewController = segue.destinationViewController as! RouteTabBarViewController
                destinationViewController.routeItem = routeItem
            }
        }
        if segue.identifier == segueCameraViewController {
            if let indexPath = favoritesTable.indexPathForSelectedRow {
                let cameraItem = self.favoriteCameras[indexPath.row] as CameraItem
                let destinationViewController = segue.destinationViewController as! CameraViewController
                destinationViewController.cameraItem = cameraItem
            }
        }
    }
}
