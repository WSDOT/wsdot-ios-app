//
//  FavoritesViewController.swift
//  wsdot
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
import RealmSwift

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let TITLE = "Favorites"
    
    let ferriesCellIdentifier = "FerriesFavoriteCell"
    let singleTitleCellIdentifier = "SingleTitleFavoriteCell"
    let travelTimesCellIdentifier = "TravelTimesCell"
    let passCellIdentifier = "PassCell"
    
    let segueTrafficMapViewController = "TrafficMapViewController"
    let segueRouteDeparturesViewController = "FavoriteSailingsViewController"
    let segueCameraViewController = "FavoriteCameraViewController"
    let segueTravelTimeViewController = "TravelTimeViewController"
    let segueMountainPassDetailsViewController = "MountianPassDetailsViewController"

    @IBOutlet weak var emptyFavoritesView: UIView!
    @IBOutlet weak var initLoadingView: UIView!
    @IBOutlet weak var favoritesTable: UITableView!
    @IBOutlet weak var initActivityIndicator: UIActivityIndicatorView!
    
    var favoriteLocations = [FavoriteLocationItem]()
    var favoriteRoutes = [FerryScheduleItem]()
    var favoriteCameras = [CameraItem]()
    var favoriteTravelTimes = [TravelTimeItem]()
    var favoritePasses = [MountainPassItem]()
    
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
    
    // Checks if users has any favorites.
    // if they do check if they favorites should be updated, if not display no favorites screen
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Favorites")
        
        self.favoriteTravelTimes = TravelTimesStore.findFavoriteTimes()
        self.favoriteRoutes = FerryRealmStore.findFavoriteSchedules()
        self.favoriteCameras = CamerasStore.getFavoriteCameras()
        self.favoriteLocations = FavoriteLocationStore.getFavorites()
        self.favoritePasses = MountainPassStore.findFavoritePasses()
        
        if (self.favoritesTableEmpty()){
            self.emptyFavoritesView.hidden = false
        }else {
            self.emptyFavoritesView.hidden = true
            self.initActivityIndicator.startAnimating()
            self.loadFavorites(false)
        }
        
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
        self.requestFavoriteTravelTimes(force, serviceGroup: serviceGroup)
        self.requestFavoriteMountainPasses(force, serviceGroup: serviceGroup)
        
        dispatch_group_notify(serviceGroup, dispatch_get_main_queue()) {
            
            self.favoriteTravelTimes = TravelTimesStore.findFavoriteTimes()
            self.favoriteRoutes = FerryRealmStore.findFavoriteSchedules()
            self.favoriteCameras = CamerasStore.getFavoriteCameras()
            self.favoriteLocations = FavoriteLocationStore.getFavorites()
            self.favoritePasses = MountainPassStore.findFavoritePasses()

            if (self.favoritesTableEmpty()){
                self.emptyFavoritesView.hidden = false
            }else {
                self.emptyFavoritesView.hidden = true
            }

            self.favoritesTable.reloadData()
            self.initActivityIndicator.stopAnimating()
            self.initLoadingView.hidden = true
            self.refreshControl.endRefreshing()
        }
    }
    
    private func requestFavoriteTravelTimes(force: Bool, serviceGroup: dispatch_group_t){
        dispatch_group_enter(serviceGroup)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) { [weak self] in
            TravelTimesStore.updateTravelTimes(force, completion: { error in
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
    
    private func requestFavoriteMountainPasses(force: Bool, serviceGroup: dispatch_group_t){
        dispatch_group_enter(serviceGroup)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {[weak self] in
            MountainPassStore.updatePasses(force, completion: { error in
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
            if self.favoritePasses.count > 0 {
                return "Mountain Passes"
            }
            return nil
        case 3:
            if self.favoriteTravelTimes.count > 0 {
                return "Travel Times"
            }
            return nil
        case 4:
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
            return favoritePasses.count
        case 3:
            return favoriteTravelTimes.count
        case 4:
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
            let passCell = tableView.dequeueReusableCellWithIdentifier(passCellIdentifier) as! MountainPassCell
            
            let passItem = favoritePasses[indexPath.row]
            
            passCell.nameLabel.text = passItem.name
            
            if (passItem.forecast.count > 0){
                passCell.forecastLabel.text = WeatherUtils.getForecastBriefDescription(passItem.forecast[0].forecastText)
                passCell.weatherImage.image = UIImage(named: WeatherUtils.getIconName(passItem.forecast[0].forecastText, title: passItem.forecast[0].day))
            } else {
                passCell.forecastLabel.text = ""
                passCell.weatherImage.image = nil
            }
            
            passCell.updatedLabel.text = TimeUtils.timeAgoSinceDate(passItem.dateUpdated, numericDates: false)
            
            return passCell
            
        case 3:
            
            let travelTimeCell = tableView.dequeueReusableCellWithIdentifier(travelTimesCellIdentifier) as! TravelTimeCell
            
            let travelTime = favoriteTravelTimes[indexPath.row]
            
            travelTimeCell.routeLabel.text = travelTime.title
            
            travelTimeCell.subtitleLabel.text = String(travelTime.distance) + " miles / " + String(travelTime.averageTime) + " min"

            do {
                let updated = try TimeUtils.timeAgoSinceDate(TimeUtils.formatTimeStamp(travelTime.updated), numericDates: false)
                travelTimeCell.updatedLabel.text = updated
            } catch TimeUtils.TimeUtilsError.InvalidTimeString {
                travelTimeCell.updatedLabel.text = "N/A"
            } catch {
                travelTimeCell.updatedLabel.text = "N/A"
            }
            
            travelTimeCell.currentTimeLabel.text = String(travelTime.currentTime) + " min"
            
            if (travelTime.averageTime > travelTime.currentTime){
                travelTimeCell.currentTimeLabel.textColor = Colors.tintColor
            } else if (travelTime.averageTime < travelTime.currentTime){
                travelTimeCell.currentTimeLabel.textColor = UIColor.redColor()
            } else {
                travelTimeCell.currentTimeLabel.textColor = UIColor.darkTextColor()
            }
            
            travelTimeCell.sizeToFit()
            
            return travelTimeCell
            
        case 4:
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
                MountainPassStore.updateFavorite(favoritePasses[indexPath.row], newValue: false)
                favoritePasses.removeAtIndex(indexPath.row)
            case 3:
                TravelTimesStore.updateFavorite(favoriteTravelTimes[indexPath.row], newValue: false)
                favoriteTravelTimes.removeAtIndex(indexPath.row)
                break
            case 4:
                CamerasStore.updateFavorite(favoriteCameras[indexPath.row], newValue: false)
                favoriteCameras.removeAtIndex(indexPath.row)
                break
            default:
                break
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            if (favoritesTableEmpty()){
                emptyFavoritesView.hidden = false
            }
            
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
            performSegueWithIdentifier(segueMountainPassDetailsViewController, sender: nil)
        case 3:
            performSegueWithIdentifier(segueTravelTimeViewController, sender: nil)
            break
        case 4:
            performSegueWithIdentifier(segueCameraViewController, sender: nil)
            break
        default:
            break
        }
    }
    
    // MARK: navigation
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
        if segue.identifier == segueMountainPassDetailsViewController {
            if let indexPath = favoritesTable.indexPathForSelectedRow {
                let passItem = self.favoritePasses[indexPath.row] as MountainPassItem
                let destinationViewController = segue.destinationViewController as! MountainPassTabBarViewController
                destinationViewController.passItem = passItem
            }
        }
        if segue.identifier == segueCameraViewController {
            if let indexPath = favoritesTable.indexPathForSelectedRow {
                let cameraItem = self.favoriteCameras[indexPath.row] as CameraItem
                let destinationViewController = segue.destinationViewController as! CameraViewController
                destinationViewController.cameraItem = cameraItem
            }
        }
        if segue.identifier == segueTravelTimeViewController {
            if let indexPath = favoritesTable.indexPathForSelectedRow {
                let travelTimeItem = self.favoriteTravelTimes[indexPath.row] as TravelTimeItem
                let destinationViewController = segue.destinationViewController as! TravelTimeDetailsViewController
                destinationViewController.travelTime = travelTimeItem
            }
        }
    }
    
    // MARK: Helpers
    func favoritesTableEmpty() -> Bool {
    return (self.favoritePasses.count == 0) &&
            (self.favoriteRoutes.count == 0) &&
            (self.favoriteCameras.count == 0) &&
            (self.favoriteLocations.count == 0) &&
            (self.favoriteTravelTimes.count == 0)
    }
}
