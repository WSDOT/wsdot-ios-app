//
//  FavroitesHomeViewController.swift
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

class FavoritesHomeViewController: UIViewController {
    
    let refreshControl = UIRefreshControl()
    var activityIndicator = UIActivityIndicatorView()

    // content types for the favorites list in order to appear on list.
    var sectionTypes: [FavoritesContent] = [.route, .ferrySchedule, .mountainPass, .camera, .travelTime]

    let segueMyRouteAlertsViewController = "MyRouteAlertsViewController"
    let segueFavoritesSettingsViewController = "FavoritesSettingsViewController"
    let segueTrafficMapViewController = "TrafficMapViewController"
    let segueRouteDeparturesViewController = "SailingsViewController"
    let segueCameraViewController = "CameraViewController"
    let segueMountainPassDetailsViewController = "MountianPassDetailsViewController"

    let textCellIdentifier = "TextCell"
    let myRouteCellIdentifier = "MyRouteFavoritesCell"
    let travelTimesCellIdentifier = "TravelTimeCell"
    let ferryScheduleCellIdentifier = "FerryScheduleCell"
    let mountainPassCellIdentifier = "MountainPassCell"

    var cameras = [CameraItem]()
    var travelTimeGroups = [TravelTimeItemGroup]()
    var ferrySchedules = [FerryScheduleItem]()
    var mountainPasses = [MountainPassItem]()
    var savedLocations = [FavoriteLocationItem]()
    var myRoutes = [MyRouteItem]()

    @IBOutlet weak var emptyFavoritesView: UIView!
    @IBOutlet weak var tableView: UITableView!

    var loadingRouteAlert = UIAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(FavoritesHomeViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        GoogleAnalytics.screenView(screenName: "/Favorites")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sectionTypes = buildSectionTypeArray()
        
        initContent()
    }

    @IBAction func favoritesSettingButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: segueFavoritesSettingsViewController, sender: self)
    }
    
    /**
     * Method name: getType
     * Description: returns the  FavoritesContent type of data help in the section.
     * Parameters: forSection: Section from above.
     */
    func getType(forSection: Int) -> FavoritesContent {
        return sectionTypes[forSection]
    }
    
    /**
     * Method name: getNumverOfRows
     * Description: using getType(), returns the size of the list corresponding to the sections data.
     * Parameters: inSection: Section from above.
     */
    func getNumberOfRows(inSection: Int) -> Int {
        switch (getType(forSection: inSection)){
        
        case .camera:
            return cameras.count
        case .travelTime:
            return travelTimeGroups.count
        case .route:
            return myRoutes.count
        case .ferrySchedule:
            return ferrySchedules.count
        case .mountainPass:
            return mountainPasses.count
        case .mapLocation:
            return savedLocations.count
        }
    }
    
    func getNumberOfSections() -> Int {
        return sectionTypes.count
    }
    
    /**
     * Method name: getTitle
     * Description: Returns a title for a section in the favorites list. 
     *              Required since sections can be changed. Uses sectionToTypeMap/
     * Parameters: forSection: The section to get a title for.
     */
    func getTitle(forSection: Int) -> String {
    
        switch (sectionTypes[forSection] ) {
        case .route:
            return myRoutes.count > 0 ? MyRouteStore.sectionTitles[FavoritesContent.route.rawValue] : ""
        case .camera:
            return cameras.count > 0 ? MyRouteStore.sectionTitles[FavoritesContent.camera.rawValue] : ""
        case .travelTime:
            return travelTimeGroups.count > 0 ? MyRouteStore.sectionTitles[FavoritesContent.travelTime.rawValue] : ""
        case .ferrySchedule:
            return ferrySchedules.count > 0 ? MyRouteStore.sectionTitles[FavoritesContent.ferrySchedule.rawValue] : ""
        case .mountainPass:
            return mountainPasses.count > 0 ? MyRouteStore.sectionTitles[FavoritesContent.mountainPass.rawValue] : ""
        case .mapLocation:
            return savedLocations.count > 0 ? MyRouteStore.sectionTitles[FavoritesContent.mapLocation.rawValue] : ""
        }
    }
    
    /**
     * Method name: buildSectionArray
     * Description: checks UserDefaults to see if we have already set the title array up.
     *              Stored in userDefaults is an array of section titles that correspoind to
     *              the types of content in the favorites lists.
     */
    func buildSectionTypeArray() -> [FavoritesContent] {
    
        var sectionTypesOrderRawArray = UserDefaults.standard.array(forKey: UserDefaultsKeys.favoritesOrder) as? [Int] ?? [Int]()
        
        // init section
        if sectionTypesOrderRawArray.count == 0 {
            sectionTypesOrderRawArray.append(FavoritesContent.route.rawValue)
            sectionTypesOrderRawArray.append(FavoritesContent.ferrySchedule.rawValue)
            sectionTypesOrderRawArray.append(FavoritesContent.mountainPass.rawValue)
            sectionTypesOrderRawArray.append(FavoritesContent.mapLocation.rawValue)
            sectionTypesOrderRawArray.append(FavoritesContent.camera.rawValue)
            sectionTypesOrderRawArray.append(FavoritesContent.travelTime.rawValue)
            UserDefaults.standard.set(sectionTypesOrderRawArray, forKey: UserDefaultsKeys.favoritesOrder)
        }
        
        var sections = [FavoritesContent]()
        
        for sectionTypeRawValue in sectionTypesOrderRawArray {
            sections.append(FavoritesContent(rawValue: sectionTypeRawValue)!)
        }
        
        return sections
    }
    

    
}

extension FavoritesHomeViewController: INDLinkLabelDelegate {}

// MARK: - Data
extension FavoritesHomeViewController {

    /**
     * Method name: initContent()
     * Description: Starts loading favorites content
     */
    func initContent(){
    
        // Check if we have any favorites to show already.
        cameras = CamerasStore.getFavoriteCameras()
        travelTimeGroups = TravelTimesStore.findFavoriteTimes()
        ferrySchedules = FerryRealmStore.findFavoriteSchedules()
        mountainPasses = MountainPassStore.findFavoritePasses()
        savedLocations = FavoriteLocationStore.getFavorites()
        myRoutes = MyRouteStore.getSelectedRoutes()
        
        if (tableEmpty()){
            emptyFavoritesView.isHidden = false
        }else {
            emptyFavoritesView.isHidden = true
        }

        loadSelectedContent(force: false)
    }

    /**
     * Method name: loadSelectedContent
     * Description: collects data from Stores to build favorites list. Uses a serviceGroup to collect data async.
     * Parameters: force: setting true will force Stores to update their data.
     */
    fileprivate func loadSelectedContent(force: Bool){

        let serviceGroup = DispatchGroup();
        
        if (self.ferrySchedules.count > 0){
            self.requestFerriesUpdate(force, serviceGroup: serviceGroup)
        }
        if (self.cameras.count > 0){
            self.requestCamerasUpdate(force, serviceGroup: serviceGroup)
        }
        if (self.travelTimeGroups.count > 0) {
            self.requestTravelTimesUpdate(force, serviceGroup: serviceGroup)
        }
        if (self.mountainPasses.count > 0){
            self.requestMountainPassesUpdate(force, serviceGroup: serviceGroup)
        }
 
        serviceGroup.notify(queue: DispatchQueue.main) {
            self.cameras = CamerasStore.getFavoriteCameras()
            self.travelTimeGroups = TravelTimesStore.findFavoriteTimes()
            self.ferrySchedules = FerryRealmStore.findFavoriteSchedules()
            self.mountainPasses = MountainPassStore.findFavoritePasses()
            self.savedLocations = FavoriteLocationStore.getFavorites()
            
            if (self.tableEmpty()){
                self.emptyFavoritesView.isHidden = false
            }else {
                self.emptyFavoritesView.isHidden = true
            }
          
            self.tableView.reloadData()
            self.hideOverlayView()
            self.refreshControl.endRefreshing()
        }
    }

    /**
     * Method name: showOverlay
     * Description: creates an loading indicator in the center of the screen.
     * Parameters: view: The view to display the loading indicator on.
     */
    func showOverlay(_ view: UIView) {
    
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor.gray
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    /**
     * Method name: hideOverlayView
     * Description: Removes the loading overlay created in showOverlay
     */
    func hideOverlayView(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }

    @objc func refreshAction(_ refreshController: UIRefreshControl){
        loadSelectedContent(force: true)
    }

    /**
     * Method name: tableEmpty
     * Description: Returns true if the favorites table is empty
     */
    func tableEmpty() -> Bool {
        return
            (self.cameras.count == 0) &&
            (self.travelTimeGroups.count == 0) &&
            (self.ferrySchedules.count == 0) &&
            (self.mountainPasses.count == 0) &&
            (self.savedLocations.count == 0) &&
            (self.myRoutes.count == 0)
    }

    func requestCamerasUpdate(_ force: Bool, serviceGroup: DispatchGroup) {
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
    
    func requestTravelTimesUpdate(_ force: Bool, serviceGroup: DispatchGroup){
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
    
    func requestFerriesUpdate(_ force: Bool, serviceGroup: DispatchGroup){
        serviceGroup.enter()
        FerryRealmStore.updateRouteSchedules(force, completion: { error in
            if (error == nil) {
                serviceGroup.leave()
            } else {
                serviceGroup.leave()
                self.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
            }
        })
    }
    
    func requestMountainPassesUpdate(_ force: Bool, serviceGroup: DispatchGroup){
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

// MARK: - TableView
extension FavoritesHomeViewController:  UITableViewDataSource, UITableViewDelegate {

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
        case .camera:
        
            let cameraCell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)

            let camera = cameras[indexPath.row]
            
            cameraCell.textLabel?.text = camera.title
            return cameraCell
        
        case .mapLocation:
            
            let locationCell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
            locationCell.textLabel?.text = savedLocations[indexPath.row].name
            return locationCell
            
        case .travelTime:
        
            let travelTimeCell = tableView.dequeueReusableCell(withIdentifier: travelTimesCellIdentifier) as! TravelTimeCell
            
            let travelTimeGroup = travelTimeGroups[indexPath.row]
            
            // Remove any labels & lines carried over from being recycled.
            for label in travelTimeCell.dynamicLabels {
                label.removeFromSuperview()
            }
            travelTimeCell.dynamicLabels.removeAll()
            for line in travelTimeCell.dynamicLines {
                line.removeFromSuperview()
            }
            travelTimeCell.dynamicLines.removeAll()
            
            travelTimeCell.routeLabel.text = travelTimeGroup.title

            // set up favorite button
            travelTimeCell.favoriteButton.isHidden = true
            
            travelTimeCell.accessoryType = .none
            travelTimeCell.isUserInteractionEnabled = false

            var lastLine: UIView? = nil
        
            for route in travelTimeGroup.routes {
            
                let line = UIView()
                line.backgroundColor = .lightGray
                line.translatesAutoresizingMaskIntoConstraints = false
                travelTimeCell.contentView.addSubview(line)
                travelTimeCell.dynamicLines.append(line)
                let negativeLineRightPadding: CGFloat = -24.0
        
                let viaLabel = UILabel()
                viaLabel.text = "Via \(route.viaText)"
                viaLabel.translatesAutoresizingMaskIntoConstraints = false
                viaLabel.numberOfLines = 0
                travelTimeCell.contentView.addSubview(viaLabel)
                travelTimeCell.dynamicLabels.append(viaLabel)
        
                let distanceLabel = UILabel()
                distanceLabel.text = "\(route.distance) miles / \(route.averageTime) min"
                distanceLabel.font = UIFont.systemFont(ofSize: 15)
                distanceLabel.translatesAutoresizingMaskIntoConstraints = false
                travelTimeCell.contentView.addSubview(distanceLabel)
                travelTimeCell.dynamicLabels.append(distanceLabel)
            
                let updatedLabel = UILabel()
                do {
                    let updated = try TimeUtils.timeAgoSinceDate(date: TimeUtils.formatTimeStamp(route.updated), numericDates: true)
                    updatedLabel.text = updated
                } catch {
                    updatedLabel.text = "N/A"
                }
            
                updatedLabel.font = UIFont.systemFont(ofSize: 15)
                updatedLabel.textColor = UIColor.lightGray
                updatedLabel.translatesAutoresizingMaskIntoConstraints = false
                travelTimeCell.contentView.addSubview(updatedLabel)
                travelTimeCell.dynamicLabels.append(updatedLabel)
        
                let timeLabel = UILabel()
            
                if (route.status == "open"){
                    timeLabel.text = "\(route.currentTime) min"
                    distanceLabel.isHidden = false
                } else {
                    distanceLabel.isHidden = true
                    timeLabel.text = route.status
                }
            
                if (route.averageTime > route.currentTime){
                    timeLabel.textColor = Colors.tintColor
                } else if (route.averageTime < route.currentTime){
                    timeLabel.textColor = UIColor.red
                } else {
                    timeLabel.textColor = UIColor.darkText
                }
            
                timeLabel.font = UIFont.systemFont(ofSize: 20)
                timeLabel.translatesAutoresizingMaskIntoConstraints = false
                travelTimeCell.contentView.addSubview(timeLabel)
                travelTimeCell.dynamicLabels.append(timeLabel)
        
                // Align labels with title
                let leadingSpaceConstraintForLine = NSLayoutConstraint(item: line, attribute: .leading, relatedBy: .equal, toItem: travelTimeCell.routeLabel, attribute: .leading, multiplier: 1, constant: 0);
                travelTimeCell.contentView.addConstraint(leadingSpaceConstraintForLine)
            
                let trailingSpaceConstraintForLine = NSLayoutConstraint(item: line, attribute: .trailing, relatedBy: .equal, toItem: travelTimeCell.contentView, attribute: .trailingMargin, multiplier: 1, constant: 8);
                travelTimeCell.contentView.addConstraint(trailingSpaceConstraintForLine)
            
                let leadingSpaceConstraintForViaLabel = NSLayoutConstraint(item: viaLabel, attribute: .leading, relatedBy: .equal, toItem: travelTimeCell.routeLabel, attribute: .leading, multiplier: 1, constant: 0);
                travelTimeCell.contentView.addConstraint(leadingSpaceConstraintForViaLabel)
        
                let trailingConstraintForViaLabel = NSLayoutConstraint(item: viaLabel, attribute: .trailing, relatedBy: .equal, toItem: travelTimeCell.contentView, attribute: .trailingMargin, multiplier: 1, constant: 8)
                travelTimeCell.contentView.addConstraint(trailingConstraintForViaLabel)
        
                let leadingSpaceConstraintForDistanceLabel = NSLayoutConstraint(item: distanceLabel, attribute: .leading, relatedBy: .equal, toItem: travelTimeCell.routeLabel, attribute: .leading, multiplier: 1, constant: 0)
                travelTimeCell.contentView.addConstraint(leadingSpaceConstraintForDistanceLabel)
            
                let leadingSpaceConstraintForUpdatedLabel = NSLayoutConstraint(item: updatedLabel, attribute: .leading, relatedBy: .equal, toItem: travelTimeCell.routeLabel, attribute: .leading, multiplier: 1, constant: 0)
                travelTimeCell.contentView.addConstraint(leadingSpaceConstraintForUpdatedLabel)
        
                // set top constraints
                let topSpaceConstraintForViaLabel = NSLayoutConstraint(item: viaLabel, attribute: .top, relatedBy: .equal, toItem: (lastLine == nil ? travelTimeCell.routeLabel : lastLine), attribute: .bottom, multiplier: 1, constant: 8);
                travelTimeCell.contentView.addConstraint(topSpaceConstraintForViaLabel)
        
                let topSpaceConstraintForDistanceLabel = NSLayoutConstraint(item: distanceLabel, attribute: .top, relatedBy: .equal, toItem: viaLabel, attribute: .bottom, multiplier: 1, constant: 8)
                travelTimeCell.contentView.addConstraint(topSpaceConstraintForDistanceLabel)
       
                let topSpaceConstraintForUpdatedLabel = NSLayoutConstraint(item: updatedLabel, attribute: .top, relatedBy: .equal, toItem: distanceLabel, attribute: .bottom, multiplier: 1, constant: 8)
                travelTimeCell.contentView.addConstraint(topSpaceConstraintForUpdatedLabel)
       
                let topSpaceConstraintForLine = NSLayoutConstraint(item: line, attribute: .top, relatedBy: .equal, toItem: updatedLabel, attribute: .bottom, multiplier: 1, constant: 8)
                travelTimeCell.contentView.addConstraint(topSpaceConstraintForLine)
       
                // Set travel time constraints
                let centerYConstraintForTimeLabel = NSLayoutConstraint(item: timeLabel, attribute: .bottom, relatedBy: .equal, toItem: updatedLabel, attribute: .bottom, multiplier: 1, constant: 0)
                travelTimeCell.contentView.addConstraint(centerYConstraintForTimeLabel)
        
                let trailingConstraintForTimeLabel = NSLayoutConstraint(item: timeLabel, attribute: .trailing, relatedBy: .equal, toItem: travelTimeCell.contentView, attribute: .trailingMargin, multiplier: 1, constant: 8)
                travelTimeCell.contentView.addConstraint(trailingConstraintForTimeLabel)
            
                // Set line contraints
                let widthConstraintForLine = NSLayoutConstraint(item: line, attribute: .width, relatedBy: .equal, toItem: travelTimeCell.contentView, attribute: .width, multiplier: 1, constant: negativeLineRightPadding)
                let heightConstraintForLine = NSLayoutConstraint(item: line, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 1)
                travelTimeCell.contentView.addConstraint(widthConstraintForLine)
                travelTimeCell.contentView.addConstraint(heightConstraintForLine)
        
                if travelTimeGroup.routes.index(of: route) == travelTimeGroup.routes.index(of: travelTimeGroup.routes.last!) {
                    let bottomSpaceConstraint = NSLayoutConstraint(item: updatedLabel, attribute: .bottom, relatedBy: .equal, toItem: travelTimeCell.contentView, attribute: .bottom, multiplier: 1, constant: -8)
                    travelTimeCell.contentView.addConstraint(bottomSpaceConstraint)
                    line.isHidden = true
                }
        
                lastLine = line
            }

        
            travelTimeCell.sizeToFit()
            
            return travelTimeCell
        
        case .ferrySchedule:
        
            let ferryCell = tableView.dequeueReusableCell(withIdentifier: ferryScheduleCellIdentifier, for: indexPath) as! RoutesCustomCell
            
            let ferryScheduleItem = ferrySchedules[indexPath.row]
            
            ferryCell.title.text = ferryScheduleItem.routeDescription
            
            if ferryScheduleItem.crossingTime != nil {
                ferryCell.subTitleOne.isHidden = false
                ferryCell.subTitleOne.text = "Crossing time: ~ " + ferryScheduleItem.crossingTime! + " min"
            } else {
                ferryCell.subTitleOne.isHidden = true
            }
            
            ferryCell.subTitleTwo.text = TimeUtils.timeAgoSinceDate(date: ferryScheduleItem.cacheDate, numericDates: true)
            
            return ferryCell
            
        case .mountainPass:
        
            let passCell = tableView.dequeueReusableCell(withIdentifier: mountainPassCellIdentifier) as! MountainPassCell
            
            let passItem = mountainPasses[indexPath.row]
            
            passCell.nameLabel.text = passItem.name
            
            if (passItem.forecast.count > 0){
                passCell.forecastLabel.text = WeatherUtils.getForecastBriefDescription(passItem.forecast[0].forecastText)
                passCell.weatherImage.image = UIImage(named: WeatherUtils.getIconName(passItem.forecast[0].forecastText, title: passItem.forecast[0].day))
            } else {
                passCell.forecastLabel.text = ""
                passCell.weatherImage.image = nil
            }
            
            passCell.updatedLabel.text = TimeUtils.timeAgoSinceDate(date: passItem.dateUpdated, numericDates: false)
            
            return passCell
            
        case .route:
        
            let routeCell = tableView.dequeueReusableCell(withIdentifier: myRouteCellIdentifier, for: indexPath) as! MyRouteFavoritesCell
            
            routeCell.checkAlertsButton.tag = indexPath.row
            routeCell.checkAlertsButton.addTarget(self, action:#selector(FavoritesHomeViewController.checkAlerts), for: .touchUpInside)
            
            routeCell.openTrafficMapButton.tag = indexPath.row
            routeCell.openTrafficMapButton.addTarget(self, action: #selector(FavoritesHomeViewController.openMap), for: .touchUpInside)
            
            routeCell.routeNameLabel.text = myRoutes[indexPath.row].name
            return routeCell
        
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /**
     * Set up custom edit actions.
     *    Delete: removes the item from favorites. If trying to delete a route, will ask for comfirmation.
     *    Rename: lets user change the name of the item. Only avaiable for a route.
     */
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let renameRouteAction = UITableViewRowAction(style: .normal, title: "Rename") { action, index in
            
            tableView.reloadRows(at: [indexPath], with: .right)
            
            let alertController = UIAlertController(title: "Edit Name", message:nil, preferredStyle: .alert)
            alertController.addTextField { (textfield) in
                textfield.placeholder = self.myRoutes[indexPath.row].name
            }
            alertController.view.tintColor = Colors.tintColor
        
            let okAction = UIAlertAction(title: "Ok", style: .default) { (_) -> Void in
        
                let textf = alertController.textFields![0] as UITextField
                var name = textf.text!
                if name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
                    name = self.myRoutes[indexPath.row].name
                }
                
                 _ = MyRouteStore.updateName(forRoute: self.myRoutes[indexPath.row], name)
                self.tableView.reloadData()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: false, completion: nil)
            
        }
        
        
        
        let renameLocationAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit", handler: { (action:UITableViewRowAction,
            indexPath:IndexPath) -> Void in
            
            tableView.reloadRows(at: [indexPath], with: .right)
            
            let alertController = UIAlertController(title: "Edit Name", message:nil, preferredStyle: .alert)
            alertController.addTextField { (textfield) in
                textfield.placeholder = self.savedLocations[indexPath.row].name
            }
            alertController.view.tintColor = Colors.tintColor

            let okAction = UIAlertAction(title: "Ok", style: .default) { (_) -> Void in
        
                let textf = alertController.textFields![0] as UITextField
                var name = textf.text!
                if name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
                    name = self.savedLocations[indexPath.row].name
                }
                
                FavoriteLocationStore.updateName(self.savedLocations[indexPath.row], name: name)
                self.tableView.reloadData()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: false, completion: nil)
            
        })
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Remove" , handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
        
            // Delete the row from the data source
            switch self.getType(forSection: indexPath.section) {
            case .mapLocation:
                FavoriteLocationStore.deleteFavorite(self.savedLocations[indexPath.row])
                self.savedLocations.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                break
            case .camera:
                CamerasStore.updateFavorite(self.cameras[indexPath.row], newValue: false)
                self.cameras.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                break
            case .travelTime:
                TravelTimesStore.updateFavorite(self.travelTimeGroups[indexPath.row], newValue: false)
                self.travelTimeGroups.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                break
            case .ferrySchedule:
                FerryRealmStore.updateFavorite(self.ferrySchedules[indexPath.row], newValue: false)
                self.ferrySchedules.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                break
            case .mountainPass:
                MountainPassStore.updateFavorite(self.mountainPasses[indexPath.row], newValue: false)
                self.mountainPasses.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                break
            case .route:
                _ = MyRouteStore.updateSelected(self.myRoutes[indexPath.row], newValue: false)
                self.myRoutes.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                break
            }
        })
        if getType(forSection: indexPath.section) == .route {
            return [deleteAction, renameRouteAction]
        } else if getType(forSection: indexPath.section) == .mapLocation {
            return [deleteAction, renameLocationAction]
        } else {
            return [deleteAction]
        }
    }
 
 // MARK: - Navigation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (getType(forSection: indexPath.section)){
        case .mapLocation:
            performSegue(withIdentifier: segueTrafficMapViewController, sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case .camera:
            performSegue(withIdentifier: segueCameraViewController, sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case .travelTime:
            break
        case .ferrySchedule:
            performSegue(withIdentifier: segueRouteDeparturesViewController, sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case .mountainPass:
            performSegue(withIdentifier: segueMountainPassDetailsViewController, sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case .route:
            tableView.deselectRow(at: indexPath, animated: true)
            break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == segueTrafficMapViewController {
        
            if let mapButton = sender as! UIButton? {
                UserDefaults.standard.set(myRoutes[mapButton.tag].displayLatitude, forKey: UserDefaultsKeys.mapLat)
                UserDefaults.standard.set(myRoutes[mapButton.tag].displayLongitude, forKey: UserDefaultsKeys.mapLon)
                UserDefaults.standard.set(myRoutes[mapButton.tag].displayZoom, forKey: UserDefaultsKeys.mapZoom)
                segue.destination.title = "Traffic Map"
            } else if let indexPath = tableView.indexPathForSelectedRow {
                let locationItem = self.savedLocations[indexPath.row] as FavoriteLocationItem
                UserDefaults.standard.set(locationItem.latitude, forKey: UserDefaultsKeys.mapLat)
                UserDefaults.standard.set(locationItem.longitude, forKey: UserDefaultsKeys.mapLon)
                UserDefaults.standard.set(locationItem.zoom, forKey: UserDefaultsKeys.mapZoom)
                segue.destination.title = "Traffic Map"
            }
        }
       
        if segue.identifier == segueMyRouteAlertsViewController {
            if let alertButton =  sender as! UIButton? {
                let destinationViewController = segue.destination as! MyRouteAlertsViewController
                destinationViewController.title = "Alerts On Route: \(myRoutes[alertButton.tag].name)"
                destinationViewController.route = myRoutes[alertButton.tag]
                destinationViewController.navigationController?.navigationBar.tintColor = Colors.tintColor
            }
        }
        
        if segue.identifier == segueCameraViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationViewController = segue.destination as! CameraPageContainerViewController
                
                destinationViewController.selectedCameraIndex = indexPath.row
                destinationViewController.cameras = self.cameras
            }
        }
        
        if segue.identifier == segueRouteDeparturesViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let routeItem = self.ferrySchedules[indexPath.row] as FerryScheduleItem
                let destinationViewController = segue.destination as! RouteTabBarViewController
                destinationViewController.title = routeItem.routeDescription
                destinationViewController.routeId = routeItem.routeId
            }
        }
        
        if segue.identifier == segueMountainPassDetailsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let passItem = self.mountainPasses[indexPath.row] as MountainPassItem
                let destinationViewController = segue.destination as! MountainPassTabBarViewController
                destinationViewController.passItem = passItem
            }
        }
    }
}

// MyRoute settings/options
extension FavoritesHomeViewController {
    /**
     * Method name: checkAlerts
     * Description: action func for check alerts button on a route cell
     */
    @objc func checkAlerts(sender: UIButton){
        GoogleAnalytics.event(category: "My Route", action: "UIAction", label: "Check Alerts")
        performSegue(withIdentifier: segueMyRouteAlertsViewController, sender: sender)
    }
    
    /**
     * Method name: checkAlerts
     * Description: action fun for openMap button on a route cell
     */
    @objc func openMap(sender: UIButton){
        GoogleAnalytics.event(category: "My Route", action: "UIAction", label: "Open Route")
        performSegue(withIdentifier: segueTrafficMapViewController, sender: sender)
    }
}

