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
    @IBOutlet weak var favoritesTable: UITableView!
    
    var favoriteLocations = [FavoriteLocationItem]()
    var favoriteRoutes = [FerryScheduleItem]()
    var favoriteCameras = [CameraItem]()
    var favoriteTravelTimes = [TravelTimeItem]()
    var favoritePasses = [MountainPassItem]()
    
    let refreshControl = UIRefreshControl()
    var activityIndicator = UIActivityIndicatorView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = TITLE
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(FavoritesViewController.loadFavoritesAction(_:)), for: .valueChanged)
        favoritesTable.addSubview(refreshControl)
        
        favoritesTable.rowHeight = UITableViewAutomaticDimension
        
        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        self.navigationItem.leftItemsSupplementBackButton = true
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
 
    }
    
    // Checks if users has any favorites.
    // if they do check if they favorites should be updated, if not display no favorites screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Favorites")
        
        self.favoriteTravelTimes = TravelTimesStore.findFavoriteTimes()
        self.favoriteRoutes = FerryRealmStore.findFavoriteSchedules()
        self.favoriteCameras = CamerasStore.getFavoriteCameras()
        self.favoriteLocations = FavoriteLocationStore.getFavorites()
        self.favoritePasses = MountainPassStore.findFavoritePasses()
        
        if (self.favoritesTableEmpty()){
            self.emptyFavoritesView.isHidden = false
        }else {
            self.emptyFavoritesView.isHidden = true
            self.showOverlay(self.view)
            self.loadFavorites(false)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if (self.isEditing){
            self.setEditing(false, animated: false)
        }
        
        if (self.favoritesTable.isEditing){
            self.favoritesTable.setEditing(false, animated: false)
        }
    }
    
    
    func loadFavoritesAction(_ refreshController: UIRefreshControl){
        loadFavorites(true)
    }
    
    fileprivate func loadFavorites(_ force: Bool){

        let serviceGroup = DispatchGroup();
        
        if (self.favoriteRoutes.count > 0){
            self.requestFavoriteFerries(force, serviceGroup: serviceGroup)
        }
        
        if (self.favoriteCameras.count > 0){
            self.requestFavoriteCameras(force, serviceGroup: serviceGroup)
        }
        
        if (self.favoriteTravelTimes.count > 0) {
            self.requestFavoriteTravelTimes(force, serviceGroup: serviceGroup)
        }
        
        if (self.favoritePasses.count > 0){
            self.requestFavoriteMountainPasses(force, serviceGroup: serviceGroup)
        }
        
        serviceGroup.notify(queue: DispatchQueue.main) {
            
            self.favoriteTravelTimes = TravelTimesStore.findFavoriteTimes()
            self.favoriteRoutes = FerryRealmStore.findFavoriteSchedules()
            self.favoriteCameras = CamerasStore.getFavoriteCameras()
            self.favoriteLocations = FavoriteLocationStore.getFavorites()
            self.favoritePasses = MountainPassStore.findFavoritePasses()

            if (self.favoritesTableEmpty()){
                self.emptyFavoritesView.isHidden = false
            }else {
                self.emptyFavoritesView.isHidden = true
            }

            self.favoritesTable.reloadData()
            self.hideOverlayView()
            self.refreshControl.endRefreshing()
        }
    }
    
    func showOverlay(_ view: UIView) {
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor.gray
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    func hideOverlayView(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }

    
    fileprivate func requestFavoriteTravelTimes(_ force: Bool, serviceGroup: DispatchGroup){
        serviceGroup.enter()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async { [weak self] in
            TravelTimesStore.updateTravelTimes(force, completion: { error in
                if (error == nil) {
                    serviceGroup.leave()
                } else {
                    serviceGroup.leave()
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    fileprivate func requestFavoriteFerries(_ force: Bool, serviceGroup: DispatchGroup){
        serviceGroup.enter()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async { [weak self] in
            FerryRealmStore.updateRouteSchedules(force, completion: { error in
                if (error == nil) {
                    serviceGroup.leave()
                } else {
                    serviceGroup.leave()
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    fileprivate func requestFavoriteCameras(_ force: Bool, serviceGroup: DispatchGroup){
        serviceGroup.enter()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {[weak self] in
            CamerasStore.updateCameras(force, completion: { error in
                if (error == nil){
                    serviceGroup.leave()
                }else{
                    serviceGroup.leave()
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    fileprivate func requestFavoriteMountainPasses(_ force: Bool, serviceGroup: DispatchGroup){
        serviceGroup.enter()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {[weak self] in
            MountainPassStore.updatePasses(force, completion: { error in
                if (error == nil){
                    serviceGroup.leave()
                }else{
                    serviceGroup.leave()
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch(indexPath.section){
        case 0:
            let locationCell = tableView.dequeueReusableCell(withIdentifier: singleTitleCellIdentifier, for: indexPath)
            locationCell.textLabel?.text = favoriteLocations[indexPath.row].name
            return locationCell
        case 1:
            let ferryCell = tableView.dequeueReusableCell(withIdentifier: ferriesCellIdentifier) as! RoutesCustomCell
            
            ferryCell.title.text = favoriteRoutes[indexPath.row].routeDescription
            
            if self.favoriteRoutes[indexPath.row].crossingTime != nil {
                ferryCell.subTitleOne.isHidden = false
                ferryCell.subTitleOne.text = "Crossing time: ~ " + self.favoriteRoutes[indexPath.row].crossingTime! + " min"
            } else {
                ferryCell.subTitleOne.isHidden = true
            }
            
            ferryCell.subTitleTwo.text = TimeUtils.timeAgoSinceDate(self.favoriteRoutes[indexPath.row].cacheDate, numericDates: true)
            
            return ferryCell
            
        case 2:
            let passCell = tableView.dequeueReusableCell(withIdentifier: passCellIdentifier) as! MountainPassCell
            
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
            
            let travelTimeCell = tableView.dequeueReusableCell(withIdentifier: travelTimesCellIdentifier) as! TravelTimeCell
            
            let travelTime = favoriteTravelTimes[indexPath.row]
            
            travelTimeCell.routeLabel.text = travelTime.title
            
            travelTimeCell.subtitleLabel.text = String(travelTime.distance) + " miles / " + String(travelTime.averageTime) + " min"

            do {
                let updated = try TimeUtils.timeAgoSinceDate(TimeUtils.formatTimeStamp(travelTime.updated), numericDates: false)
                travelTimeCell.updatedLabel.text = updated
            } catch TimeUtils.TimeUtilsError.invalidTimeString {
                travelTimeCell.updatedLabel.text = "N/A"
            } catch {
                travelTimeCell.updatedLabel.text = "N/A"
            }
            
            travelTimeCell.currentTimeLabel.text = String(travelTime.currentTime) + " min"
            
            if (travelTime.averageTime > travelTime.currentTime){
                travelTimeCell.currentTimeLabel.textColor = Colors.tintColor
            } else if (travelTime.averageTime < travelTime.currentTime){
                travelTimeCell.currentTimeLabel.textColor = UIColor.red
            } else {
                travelTimeCell.currentTimeLabel.textColor = UIColor.darkText
            }
            
            travelTimeCell.sizeToFit()
            
            return travelTimeCell
            
        case 4:
            let cameraCell = tableView.dequeueReusableCell(withIdentifier: singleTitleCellIdentifier, for: indexPath)
            cameraCell.textLabel?.text = favoriteCameras[indexPath.row].title
            return cameraCell
            
        default:
            return tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)

        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.favoritesTable.setEditing(editing, animated: animated)
    }

    // support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            switch (indexPath.section) {
            case 0:
                FavoriteLocationStore.deleteFavorite(favoriteLocations[indexPath.row])
                favoriteLocations.remove(at: indexPath.row)
            case 1:
                FerryRealmStore.updateFavorite(favoriteRoutes[indexPath.row], newValue: false)
                favoriteRoutes.remove(at: indexPath.row)
            case 2:
                MountainPassStore.updateFavorite(favoritePasses[indexPath.row], newValue: false)
                favoritePasses.remove(at: indexPath.row)
            case 3:
                TravelTimesStore.updateFavorite(favoriteTravelTimes[indexPath.row], newValue: false)
                favoriteTravelTimes.remove(at: indexPath.row)
                break
            case 4:
                CamerasStore.updateFavorite(favoriteCameras[indexPath.row], newValue: false)
                favoriteCameras.remove(at: indexPath.row)
                break
            default:
                break
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if (favoritesTableEmpty()){
                emptyFavoritesView.isHidden = false
            }
            
        }
    }
    
    // MARK: - Navigation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section){
        case 0:
            performSegue(withIdentifier: segueTrafficMapViewController, sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 1:
            performSegue(withIdentifier: segueRouteDeparturesViewController, sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 2:
            performSegue(withIdentifier: segueMountainPassDetailsViewController, sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        case 3:
            performSegue(withIdentifier: segueTravelTimeViewController, sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 4:
            performSegue(withIdentifier: segueCameraViewController, sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        default:
            break
        }
    }
    
    // MARK: navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == segueTrafficMapViewController {
            if let indexPath = favoritesTable.indexPathForSelectedRow {
                let locationItem = self.favoriteLocations[indexPath.row] as FavoriteLocationItem
                UserDefaults.standard.set(locationItem.latitude, forKey: UserDefaultsKeys.mapLat)
                UserDefaults.standard.set(locationItem.longitude, forKey: UserDefaultsKeys.mapLon)
                UserDefaults.standard.set(locationItem.zoom, forKey: UserDefaultsKeys.mapZoom)
                segue.destination.title = "Traffic Map"
            }
        }
        if segue.identifier == segueRouteDeparturesViewController {
            if let indexPath = favoritesTable.indexPathForSelectedRow {
                let routeItem = self.favoriteRoutes[indexPath.row] as FerryScheduleItem
                let destinationViewController = segue.destination as! RouteTabBarViewController
                destinationViewController.routeItem = routeItem
            }
        }
        if segue.identifier == segueMountainPassDetailsViewController {
            if let indexPath = favoritesTable.indexPathForSelectedRow {
                let passItem = self.favoritePasses[indexPath.row] as MountainPassItem
                let destinationViewController = segue.destination as! MountainPassTabBarViewController
                destinationViewController.passItem = passItem
            }
        }
        if segue.identifier == segueCameraViewController {
            if let indexPath = favoritesTable.indexPathForSelectedRow {
                let cameraItem = self.favoriteCameras[indexPath.row] as CameraItem
                let destinationViewController = segue.destination as! CameraViewController
                destinationViewController.cameraItem = cameraItem
            }
        }
        if segue.identifier == segueTravelTimeViewController {
            if let indexPath = favoritesTable.indexPathForSelectedRow {
                let travelTimeItem = self.favoriteTravelTimes[indexPath.row] as TravelTimeItem
                let destinationViewController = segue.destination as! TravelTimeDetailsViewController
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
