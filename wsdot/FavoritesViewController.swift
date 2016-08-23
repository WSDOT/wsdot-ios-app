//
//  FavoritesViewController.swift
//  wsdot
//
//  Created by Logan Sims on 6/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit
import RealmSwift

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let TITLE = "Favorites"
    
    let ferriesCellIdentifier = "FerriesFavoriteCell"
    let singleTitleCellIdentifier = "SingleTitleFavoriteCell"
    
    let segueTrafficMapViewController = "TrafficMapViewController"
    let segueRouteDeparturesViewController = "FavoriteSailingsViewController"
    let segueCameraViewController = "FavoriteCameraViewController"

    @IBOutlet weak var favoritesTable: UITableView!
    
    var favoriteLocations = [FavoriteLocationItem]()
    var favoriteRoutes = [FerryScheduleItem]()
    var favoriteCameras = [CameraItem]()
    
    var notificationToken: NotificationToken?
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = TITLE
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(FavoritesViewController.loadFavoritesAction(_:)), forControlEvents: .ValueChanged)
        favoritesTable.addSubview(refreshControl)
        
        favoritesTable.rowHeight = UITableViewAutomaticDimension
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadFavorites(false)
    }
    
    override func viewDidDisappear(animated: Bool) {
        if (self.editing){
            self.setEditing(false, animated: false)
        }
        
        if (self.favoritesTable.editing){
            self.favoritesTable.setEditing(false, animated: false)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Initialize Tab Bar Item
        tabBarItem = UITabBarItem(title: TITLE, image: UIImage(named: "ic-star"), tag: 1)
    }
    
    func loadFavoritesAction(refreshController: UIRefreshControl){
        loadFavorites(true)
    
    }
    
    private func loadFavorites(force: Bool){
        let serviceGroup = dispatch_group_create();
        
        self.requestFavoriteFerries(force, serviceGroup: serviceGroup)
        self.requestFavoriteCameras(force, serviceGroup: serviceGroup)
        
        dispatch_group_notify(serviceGroup, dispatch_get_main_queue()) {
            
            self.favoriteRoutes = FerryRealmStore.findFavoriteSchedules()
            self.favoriteCameras = CamerasStore.getFavoriteCameras()
            self.favoriteLocations = FavoriteLocationStore.getFavorites()

            self.favoritesTable.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    private func requestFavoriteFerries(force: Bool, serviceGroup: dispatch_group_t){
        dispatch_group_enter(serviceGroup)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) { [weak self] in
            FerryRealmStore.updateRouteSchedules(force, completion: { error in
                if (error == nil) {
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
    
    private func requestFavoriteCameras(force: Bool, serviceGroup: dispatch_group_t){
        dispatch_group_enter(serviceGroup)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {[weak self] in
            CamerasStore.updateCameras(force, completion: { error in
                if (error == nil){
                    dispatch_group_leave(serviceGroup)
                }else{
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
            if self.favoriteLocations.count > 0 {
                return "Locations"
            }
            return nil
        case 1:
            if self.favoriteRoutes.count > 0 {
                return "Ferry Schedules"
            }
            return nil
        case 2:
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
            return favoriteLocations.count
        case 1:
            return favoriteRoutes.count
        case 2:
            return favoriteCameras.count
        default:
            return 0
        }
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch(indexPath.section){
        case 0:
            let locationCell = tableView.dequeueReusableCellWithIdentifier(singleTitleCellIdentifier, forIndexPath: indexPath)
            locationCell.textLabel?.text = favoriteLocations[indexPath.row].name
            return locationCell
        case 1:
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
            
        case 2:
            let cameraCell = tableView.dequeueReusableCellWithIdentifier(singleTitleCellIdentifier, forIndexPath: indexPath)
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
                FavoriteLocationStore.deleteFavorite(favoriteLocations[indexPath.row])
                favoriteLocations.removeAtIndex(indexPath.row)
            case 1:
                FerryRealmStore.updateFavorite(favoriteRoutes[indexPath.row], newValue: false)
                favoriteRoutes.removeAtIndex(indexPath.row)
            case 2:
                CamerasStore.updateFavorite(favoriteCameras[indexPath.row], newValue: false)
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
            performSegueWithIdentifier(segueTrafficMapViewController, sender: nil)
            break
        case 1:
            performSegueWithIdentifier(segueRouteDeparturesViewController, sender: nil)
            break
        case 2:
            performSegueWithIdentifier(segueCameraViewController, sender: nil)
            break
        default:
            break
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == segueTrafficMapViewController {
            if let indexPath = favoritesTable.indexPathForSelectedRow {
                let locationItem = self.favoriteLocations[indexPath.row] as FavoriteLocationItem
                NSUserDefaults.standardUserDefaults().setObject(locationItem.latitude, forKey: UserDefaultsKeys.mapLat)
                NSUserDefaults.standardUserDefaults().setObject(locationItem.longitude, forKey: UserDefaultsKeys.mapLon)
                NSUserDefaults.standardUserDefaults().setObject(locationItem.zoom, forKey: UserDefaultsKeys.mapZoom)
            }
        }
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
