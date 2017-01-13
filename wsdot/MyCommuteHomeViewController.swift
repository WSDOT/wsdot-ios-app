//
//  MyCommuteHomeViewController.swift
//  WSDOT
//
//  Copyright (c) 2017 Washington State Department of Transportation
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

class MyCommuteHomeViewController: UIViewController {

    enum MyCommuteContent {
        case alert // Highway alerts releated to users route
        case camera // User selected cameras or cameras on user route
        case travelTimes // user selected travel times or time on users route
        case route // traffic map showing users route.
    }
    
    let refreshControl = UIRefreshControl()
    var activityIndicator = UIActivityIndicatorView()

    var sectionToTypeMap = [Int:MyCommuteContent]()

    let segueNewMyCommuteViewController = "NewMyCommuteViewController"

    let alertCellIdentifier = "HighwayAlertCell"
    let textCellIdentifier = "TextCell"
    
    var cameras = [CameraItem]()
    var alerts = [HighwayAlertItem]()
    var travelTimes = [TravelTimeItem]()
    
    var myCommute: MyCommuteItem?
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(MyCommuteHomeViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        sectionToTypeMap[1] = .alert
        sectionToTypeMap[0] = .route
        sectionToTypeMap[2] = .camera
        sectionToTypeMap[3] = .travelTimes
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initContent()
    }

    @IBAction func createNewRouteButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: segueNewMyCommuteViewController, sender: self)
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        self.tableView.setEditing(!tableView.isEditing, animated: true)
        sender.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    func getType(forSection: Int) -> MyCommuteContent {
        return sectionToTypeMap[forSection] ?? .alert
    }
    
    func getNumberOfRows(inSection: Int) -> Int {
        switch (getType(forSection: inSection)){
        
        case .alert:
            return alerts.count
        case .camera:
            return cameras.count
        case .travelTimes:
            return travelTimes.count
        case .route:
            if MyCommuteRealmStore.getSavedCommute() != nil {
                return 1
            } else {
                return 0
            }
        }
    }
    
    func getNumberOfSections() -> Int {
        return sectionToTypeMap.count
    }
    
    func getTitle(forSection: Int) -> String {
    
        switch (sectionToTypeMap[forSection] ?? .alert) {
        
        case .alert:
            if myCommute == nil {
                return ""
            } else if alerts.count > 0 {
                return "Alerts on Route"
            } else {
                return "No Reported Alerts on Route"
            }
        case .camera:
            return cameras.count > 0 ? "Cameras" : ""
        case .travelTimes:
            return travelTimes.count > 0 ? "Travel Times" : ""
        case .route:
            return myCommute == nil ? "" : "Saved Route"
        }
    }
    
}

extension MyCommuteHomeViewController: INDLinkLabelDelegate {}

// Content updating extension
extension MyCommuteHomeViewController {


    func initContent(){
        if let value = MyCommuteRealmStore.getSavedCommute() {
            myCommute = value
        
            // First time loading this route, retrieve nearby items
            if !myCommute!.hasFoundNearbyItems {
                
                let serviceGroup = DispatchGroup();
                
                requestSelectedCameras(serviceGroup: serviceGroup, force: true)
                // Add more items that can be collected from user route...
                
                serviceGroup.notify(queue: DispatchQueue.main) {
                    
                    do {
                        _ = try MyCommuteRealmStore.selectNearbyCameras(forCommute: self.myCommute!)
                    } catch {
                        // Print alert error about getting content form route.
                    }
                    
                    self.getContent(false)
    
                }
            } else {
                getContent(false)
            }
        } else {
            getContent(false)
        }
    }

    func getContent(_ force: Bool){
    
        // Check if user made a route
        if let value = MyCommuteRealmStore.getSavedCommute() {
            myCommute = value
            
            let serviceGroup = DispatchGroup();
                
            requestSelectedAlerts(serviceGroup: serviceGroup, force: force)
                
            serviceGroup.notify(queue: DispatchQueue.main) {
                    
                self.alerts = MyCommuteRealmStore.getNearbyAlerts(forCommute: self.myCommute!, withAlerts: HighwayAlertsStore.getAllAlerts())
                
                self.loadSelectedContent(force)
            }
            
        } else {
            loadSelectedContent(force)
        }
        
    }
    
    fileprivate func loadSelectedContent(_ force: Bool){

        let serviceGroup = DispatchGroup();
        
        /*
        if (self.favoriteRoutes.count > 0){
            self.requestFavoriteFerries(force, serviceGroup: serviceGroup)
        }
        */
        
        if (self.cameras.count > 0){
            self.requestSelectedCameras(serviceGroup: serviceGroup, force: force)
        }
        
        /*
        if (self.favoriteTravelTimes.count > 0) {
            self.requestFavoriteTravelTimes(force, serviceGroup: serviceGroup)
        }
        
        if (self.favoritePasses.count > 0){
            self.requestFavoriteMountainPasses(force, serviceGroup: serviceGroup)
        }
        */
 
        serviceGroup.notify(queue: DispatchQueue.main) {
            
           // self.favoriteTravelTimes = TravelTimesStore.findFavoriteTimes()
           // self.favoriteRoutes = FerryRealmStore.findFavoriteSchedules()
            self.cameras = CamerasStore.getFavoriteCameras()
           // self.favoriteLocations = FavoriteLocationStore.getFavorites()
           // self.favoritePasses = MountainPassStore.findFavoritePasses()
/*
            if (self.favoritesTableEmpty()){
                self.emptyFavoritesView.isHidden = false
            }else {
                self.emptyFavoritesView.isHidden = true
            }
*/
          
            self.tableView.reloadData()
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

    func refreshAction(_ refreshController: UIRefreshControl){
        getContent(true)
    }

    func tableEmpty() -> Bool {
        return (self.cameras.count == 0) &&
            (self.alerts.count == 0)
    }

    


    fileprivate func requestSelectedCameras(serviceGroup: DispatchGroup, force: Bool) {
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
    
    fileprivate func requestSelectedAlerts(serviceGroup: DispatchGroup, force: Bool) {
        serviceGroup.enter()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {[weak self] in
            HighwayAlertsStore.updateAlerts(force, completion: { error in
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
    
    fileprivate func requestSelectedTravelTimes(_ force: Bool, serviceGroup: DispatchGroup){
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
    
    fileprivate func requestSelectedFerries(_ force: Bool, serviceGroup: DispatchGroup){
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
    
    fileprivate func requestSelectedMountainPasses(_ force: Bool, serviceGroup: DispatchGroup){
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

}

extension MyCommuteHomeViewController:  UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getTitle(forSection: section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getNumberOfRows(inSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch getType(forSection: indexPath.section) {
        
        case .alert:
        
            let alertCell = tableView.dequeueReusableCell(withIdentifier: alertCellIdentifier, for: indexPath) as! LinkCell
            let htmlStyleString = "<style>body{font-family: '\(alertCell.linkLabel.font.fontName)'; font-size:\(alertCell.linkLabel.font.pointSize)px;}</style>"
            var htmlString = ""
            
            //cell.updateTime.text = TimeUtils.timeAgoSinceDate(date: trafficAlerts[indexPath.row].lastUpdatedTime, numericDates: false)
            htmlString = htmlStyleString + alerts[indexPath.row].headlineDesc
            let attrStr = try! NSMutableAttributedString(
                data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
                options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil)
        
            switch (alerts[indexPath.row].priority){
            
            case "highest":
                alertCell.backgroundColor = UIColor(red: 255/255, green: 232/255, blue: 232/255, alpha: 1.0) /* #ffe8e8 */
                break
            case "high":
                alertCell.backgroundColor = UIColor(red: 255/255, green: 244/255, blue: 232/255, alpha: 1.0) /* #fff4e8 */
                break
            default:
                alertCell.backgroundColor = UIColor(red: 255/255, green: 254/255, blue: 232/255, alpha: 1.0) /* #fffee8 */
            }
        
            alertCell.linkLabel.attributedText = attrStr
            alertCell.linkLabel.delegate = self
        
            alertCell.updateTime.text = TimeUtils.timeAgoSinceDate(date: alerts[indexPath.row].lastUpdatedTime, numericDates: false)
            
            return alertCell
        
        case .camera:
        
            let cameraCell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)

            let camera = cameras[indexPath.row]
            
            cameraCell.textLabel?.text = camera.title
            return cameraCell
        
        case .travelTimes:
        
            let cameraCell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)

            let camera = cameras[indexPath.row]
            
            cameraCell.textLabel?.text = camera.title
            return cameraCell
        
        case .route:
        
            let routeCell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
            
            routeCell.textLabel?.text = myCommute!.name
            return routeCell
        
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    
        if getType(forSection: indexPath.section) == .alert {
            return true
        }
    
        return tableView.isEditing
 
    }
    
    
    // support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Delete the row from the data source
            switch getType(forSection: indexPath.section) {
            case .alert:
            
                break
            case .camera:
                CamerasStore.updateFavorite(cameras[indexPath.row], newValue: false)
                cameras.remove(at: indexPath.row)
                break
            case .travelTimes:
                break
            case .route:
                _ = MyCommuteRealmStore.delete(route: myCommute!)
                myCommute = nil
                break
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)

        }
    }
}
