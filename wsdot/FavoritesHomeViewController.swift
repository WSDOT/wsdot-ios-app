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

class FavoritesHomeViewController: RefreshViewController {
    
    let refreshControl = UIRefreshControl()

    // content types for the favorites list in order to appear on list.
    var sectionTypes: [FavoritesContent] = [.route, .ferrySchedule, .mountainPass, .camera, .travelTime, .tollRate, .borderWait]

    let segueMyRouteReportViewController = "MyRouteReportViewController"
    let segueFavoritesSettingsViewController = "FavoritesSettingsViewController"
    let segueTrafficMapViewController = "TrafficMapViewController"
    let segueRouteDeparturesViewController = "SailingsViewController"
    let segueRouteAlertsViewController = "RouteAlertsViewController"
    let segueCameraViewController = "CameraViewController"
    let segueMountainPassDetailsViewController = "MountianPassDetailsViewController"

    let textCellIdentifier = "TextCell"
    let myRouteCellIdentifier = "MyRouteFavoritesCell"
    let travelTimesCellIdentifier = "TravelTimeCell"
    let ferryScheduleCellIdentifier = "FerryScheduleCell"
    let mountainPassCellIdentifier = "MountainPassCell"
    let tollRatesCellIdentifier = "TollRatesCell"
    let borderWaitCellIdentifier = "BorderWaitCell"

    var cameras = [CameraItem]()
    var travelTimeGroups = [TravelTimeItemGroup]()
    var ferrySchedules = [FerryScheduleItem]()
    var mountainPasses = [MountainPassItem]()
    var savedLocations = [FavoriteLocationItem]()
    var myRoutes = [MyRouteItem]()
    var tollRates = [TollRateSignItem]()
    var borderWaits = [BorderWaitItem]()
    
    let mountainPassViewController = MountainPassesViewController()
    

    @IBOutlet weak var emptyFavoritesView: UIView!
    @IBOutlet weak var tableView: UITableView!

    var loadingRouteAlert = UIAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(FavoritesHomeViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sectionTypes = buildSectionTypeArray()
        initContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "Favorites")
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
        case .tollRate:
            return tollRates.count
        case .borderWait:
            return borderWaits.count
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
        case .tollRate:
            return tollRates.count > 0 ? MyRouteStore.sectionTitles[FavoritesContent.tollRate.rawValue] : ""
        case .borderWait:
            return borderWaits.count > 0 ? MyRouteStore.sectionTitles[FavoritesContent.borderWait.rawValue] : ""
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
            sectionTypesOrderRawArray.append(FavoritesContent.tollRate.rawValue)
            sectionTypesOrderRawArray.append(FavoritesContent.borderWait.rawValue)
            UserDefaults.standard.set(sectionTypesOrderRawArray, forKey: UserDefaultsKeys.favoritesOrder)
        } else if sectionTypesOrderRawArray.count < 7 { // Add toll rates & border waits
            sectionTypesOrderRawArray.append(FavoritesContent.tollRate.rawValue)
            sectionTypesOrderRawArray.append(FavoritesContent.borderWait.rawValue)
            UserDefaults.standard.set(sectionTypesOrderRawArray, forKey: UserDefaultsKeys.favoritesOrder)
        } else if sectionTypesOrderRawArray.count < 8 { // Added border waits
            sectionTypesOrderRawArray.append(FavoritesContent.borderWait.rawValue)
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
        tollRates = TollRateSignsStore.findFavoriteTollSigns()
        borderWaits = BorderWaitStore.getFavoriteWaits()
        
        if (tableEmpty()){
            emptyFavoritesView.isHidden = false
        }else {
            emptyFavoritesView.isHidden = true
        }

        loadSelectedContent(force: true)
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
        if (self.tollRates.count > 0){
            self.requestTollRatesUpdate(force, serviceGroup: serviceGroup)
        }
        if (self.borderWaits.count > 0){
            self.requestBorderWaitsUpdate(force, serviceGroup: serviceGroup)
        }
 
        serviceGroup.notify(queue: DispatchQueue.main) {

            self.cameras = CamerasStore.getFavoriteCameras()
            self.travelTimeGroups = TravelTimesStore.findFavoriteTimes()
            self.ferrySchedules = FerryRealmStore.findFavoriteSchedules()
            self.mountainPasses = MountainPassStore.findFavoritePasses()
            self.savedLocations = FavoriteLocationStore.getFavorites()
            self.tollRates = TollRateSignsStore.findFavoriteTollSigns()
            self.borderWaits = BorderWaitStore.getFavoriteWaits()
            
            if (self.tableEmpty()){
                self.emptyFavoritesView.isHidden = false
            }else {
                self.emptyFavoritesView.isHidden = true
            }
            
            MountainPassStore.flushOldData()

            self.tableView.reloadData()
            self.hideOverlayView()
            self.refreshControl.endRefreshing()
        }
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
            (self.tollRates.count == 0) &&
            (self.myRoutes.count == 0) &&
            (self.borderWaits.count == 0)
    }

    func requestCamerasUpdate(_ force: Bool, serviceGroup: DispatchGroup) {
        serviceGroup.enter()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
            CamerasStore.updateCameras(force, completion: { error in
                if (error == nil){
                    serviceGroup.leave()
                }else{
                    serviceGroup.leave()
                    // no error message since cameras don't need to be refreshed to show in favorites
                }
            })
        }
    }
    
    func requestTravelTimesUpdate(_ force: Bool, serviceGroup: DispatchGroup){
        serviceGroup.enter()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
            TravelTimesStore.updateTravelTimes(force, completion: { error in
                if (error == nil) {
                    serviceGroup.leave()
                } else {
                    serviceGroup.leave()
                    DispatchQueue.main.async {
                        AlertMessages.getConnectionAlert(backupURL: nil, message: WSDOTErrorStrings.favorites)
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
                DispatchQueue.main.async {
                    AlertMessages.getConnectionAlert(backupURL: nil, message: WSDOTErrorStrings.favorites)
                }
            }
        })
    }
    
    func requestMountainPassesUpdate(_ force: Bool, serviceGroup: DispatchGroup){
        serviceGroup.enter()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
            MountainPassStore.updatePasses(force, completion: { error in
                if (error == nil){
                    serviceGroup.leave()
                }else{
                    serviceGroup.leave()
                    DispatchQueue.main.async {
                        AlertMessages.getConnectionAlert(backupURL: nil, message: WSDOTErrorStrings.favorites)
                    }
                }
            })
        }
    }
    
    func requestTollRatesUpdate(_ force: Bool, serviceGroup: DispatchGroup) {
        serviceGroup.enter()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
            TollRateSignsStore.updateTollRateSigns(force, completion: { error in
                if (error == nil) {
                    serviceGroup.leave()
                } else {
                    serviceGroup.leave()
                    DispatchQueue.main.async {
                        AlertMessages.getConnectionAlert(backupURL: nil, message: WSDOTErrorStrings.favorites)
                    }
                }
            })
        }
    }
    
    func requestBorderWaitsUpdate(_ force: Bool, serviceGroup: DispatchGroup) {
        serviceGroup.enter()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
            BorderWaitStore.updateWaits(force, completion: { error in
                if (error == nil) {
                    serviceGroup.leave()
                } else {
                    serviceGroup.leave()
                    DispatchQueue.main.async {
                        AlertMessages.getConnectionAlert(backupURL: nil, message: WSDOTErrorStrings.favorites)
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
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
        
            let travelTimeCell = tableView.dequeueReusableCell(withIdentifier: travelTimesCellIdentifier) as! GroupRouteCell
            
            let travelTimeGroup = travelTimeGroups[indexPath.row]
            
            // Remove any RouteViews carried over from being recycled.
            for route in travelTimeCell.dynamicRouteViews {
                route.removeFromSuperview()
            }
            travelTimeCell.dynamicRouteViews.removeAll()
            
            travelTimeCell.routeLabel.text = travelTimeGroup.title

            // set up favorite button
            travelTimeCell.favoriteButton.isHidden = true
            
            travelTimeCell.accessoryType = .none
            travelTimeCell.isUserInteractionEnabled = false

            var lastRouteView: RouteView? = nil
        
            for route in travelTimeGroup.routes {
        
                let routeView = RouteView.instantiateFromXib()
            
                routeView.translatesAutoresizingMaskIntoConstraints = false
                routeView.contentView.translatesAutoresizingMaskIntoConstraints = false
                routeView.titleLabel.translatesAutoresizingMaskIntoConstraints = false
                routeView.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
                routeView.updatedLabel.translatesAutoresizingMaskIntoConstraints = false
                routeView.valueLabel.translatesAutoresizingMaskIntoConstraints = false
            
                routeView.titleLabel.text = "Via \(route.viaText)"
                routeView.subtitleLabel.text = "\(route.distance) miles / \(route.averageTime) min"
            
                do {
                    let updated = try TimeUtils.timeAgoSinceDate(date: TimeUtils.formatTimeStamp(route.updated), numericDates: true)
                    routeView.updatedLabel.text = updated
                } catch {
                    routeView.updatedLabel.text = "N/A"
                }
            
                if (route.status == "open"){
                    routeView.valueLabel.text = "\(route.currentTime) min"
                    routeView.subtitleLabel.isHidden = false
                } else {
                    routeView.subtitleLabel.isHidden = true
                    routeView.valueLabel.text = route.status
                }
            
                if (route.averageTime > route.currentTime){
                    routeView.valueLabel.textColor = Colors.tintColor
                } else if (route.averageTime < route.currentTime){
                    routeView.valueLabel.textColor = UIColor.red
                } else {
                    if #available(iOS 13, *) {
                        routeView.valueLabel.textColor = UIColor.label
                    } else {
                        routeView.valueLabel.textColor = UIColor.darkText
                    }
                }
                
                if (route.currentTime == -1) {
                    routeView.valueLabel.text = "N/A"
                    routeView.subtitleLabel.text = "Not Available"
                    if #available(iOS 13.0, *) {
                        routeView.valueLabel.textColor = UIColor.label
                    } else {
                        routeView.valueLabel.textColor = UIColor.darkText
                    }
                }
            
                travelTimeCell.contentView.addSubview(routeView)
            
                routeView.contentView.leadingAnchor.constraint(equalTo: travelTimeCell.routeLabel.leadingAnchor).isActive = true
                routeView.contentView.trailingAnchor.constraint(equalTo: travelTimeCell.routeLabel.trailingAnchor, constant: 8).isActive = true
                routeView.contentView.topAnchor.constraint(equalTo: (lastRouteView == nil ? travelTimeCell.routeLabel.bottomAnchor : lastRouteView!.updatedLabel.bottomAnchor), constant: (lastRouteView == nil ? 0 : 8)).isActive = true

                if travelTimeGroup.routes.index(of: route) == travelTimeGroup.routes.index(of: travelTimeGroup.routes.last!) {
                       
                    routeView.updatedLabel.bottomAnchor.constraint(equalTo: travelTimeCell.contentView.bottomAnchor, constant: -16).isActive = true
 
                    routeView.line.isHidden = true
                }

                travelTimeCell.dynamicRouteViews.append(routeView)
                lastRouteView = routeView
            
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
            passCell.nameLabel.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .title3).fontDescriptor.withSymbolicTraits(.traitBold)!, size: UIFont.preferredFont(forTextStyle: .title3).pointSize)
            
            // Weather Icon
            if (passItem.weatherCondition != ""){
                passCell.weatherImage.image = UIImage(named: WeatherUtils.getDailyWeatherIconName(passItem.weatherCondition, index: 0))
            }
            
            else if (passItem.forecast.count > 0){

                // Check first sentence in forecast for icon match
                if ((UIImage(named: WeatherUtils.getDailyWeatherIconName(passItem.forecast[0].forecastText, index: 0))) != nil) {
                    passCell.weatherImage.image = UIImage(named: WeatherUtils.getDailyWeatherIconName(passItem.forecast[0].forecastText, index: 0))

                }
                
                // Check second sentence in forecast for icon match
                else {
                    passCell.weatherImage.image = UIImage(named: WeatherUtils.getDailyWeatherIconName(passItem.forecast[0].forecastText, index: 1))
                }
                
            }
            
            else {
                passCell.weatherImage.image = nil
            }
            
            // Travel Restrictions Text
            passCell.restrictionsOneLabel.attributedText = mountainPassViewController.restrictionLabel(label: "Travel ", direction: passItem.restrictionOneTravelDirection, passItem: passItem.restrictionOneText)
            passCell.restrictionsTwoLabel.attributedText = mountainPassViewController.restrictionLabel(label: "Travel ", direction: passItem.restrictionTwoTravelDirection, passItem: passItem.restrictionTwoText)
            
            // Check if advisory is active
            if (!passItem.travelAdvisoryActive) {
                passCell.restrictionsOneLabel.isHidden = true
                passCell.restrictionsTwoLabel.isHidden = true
            }
            else {
                passCell.restrictionsOneLabel.isHidden = false
                passCell.restrictionsTwoLabel.isHidden = false
            }
            
            return passCell
            
        case .tollRate:
         
            let tollRateCell = tableView.dequeueReusableCell(withIdentifier: tollRatesCellIdentifier) as! GroupRouteCell
        
            // Remove any RouteViews carried over from being recycled.
            for route in tollRateCell.dynamicRouteViews {
                route.removeFromSuperview()
            }
        
            tollRateCell.dynamicRouteViews.removeAll()
        
            let tollSign = tollRates[indexPath.row]

            tollRateCell.routeLabel.text = "\(tollSign.stateRoute) - \(tollSign.locationTitle)"
        
            // set up favorite button
            tollRateCell.favoriteButton.isHidden = true
            
            var lastTripView: TollTripView? = nil
        
            for trip in tollSign.trips {
        
                let tripView = TollTripView.instantiateFromXib()
            
                tripView.translatesAutoresizingMaskIntoConstraints = false
                tripView.contentView.translatesAutoresizingMaskIntoConstraints = false
                tripView.topLabel.translatesAutoresizingMaskIntoConstraints = false
                tripView.bottomLabel.translatesAutoresizingMaskIntoConstraints = false
                tripView.actionButton.translatesAutoresizingMaskIntoConstraints = false
                tripView.valueLabel.translatesAutoresizingMaskIntoConstraints = false
            
                tripView.actionButton.isHidden = true
                
                if tollSign.stateRoute == 405 {
                    tripView.topLabel.text = "to \(trip.endLocationName)"
                } else {
                    tripView.topLabel.text = "Carpools and motorcycles free"
                }
            
                tripView.bottomLabel.text = TimeUtils.timeAgoSinceDate(date: trip.updatedAt, numericDates: true)
            
                if (trip.message == ""){
                    tripView.valueLabel.text = "$" + String(format: "%.2f", locale: Locale.current, arguments: [trip.toll])
                } else {
                    tripView.valueLabel.text = trip.message
                }
            
                tollRateCell.contentView.addSubview(tripView)
                  
                tripView.contentView.leadingAnchor.constraint(equalTo: tollRateCell.routeLabel.leadingAnchor).isActive = true
                tripView.contentView.trailingAnchor.constraint(equalTo: tollRateCell.routeLabel.trailingAnchor, constant: 8).isActive = true
                tripView.contentView.topAnchor.constraint(equalTo: (lastTripView == nil ? tollRateCell.routeLabel.bottomAnchor : lastTripView!.bottomLabel.bottomAnchor), constant: (lastTripView == nil ? 0 : 8)).isActive = true
                 if tollSign.trips.index(of: trip) == tollSign.trips.index(of: tollSign.trips.last!) {
                           
                    tripView.bottomLabel.bottomAnchor.constraint(equalTo: tollRateCell.contentView.bottomAnchor, constant: -16).isActive = true
                    tripView.line.isHidden = true
                }
            
                tollRateCell.dynamicRouteViews.append(tripView)
                lastTripView = tripView
           
            }

            tollRateCell.sizeToFit()
            return tollRateCell
            
        case .borderWait:
        
            let waitCell = tableView.dequeueReusableCell(withIdentifier: borderWaitCellIdentifier) as! BorderWaitCell
        
            let wait = borderWaits[indexPath.row]
        
            waitCell.nameLabel.text = wait.name + " (" + wait.lane + ")"
        
            do {
                let updated = try TimeUtils.timeAgoSinceDate(date: TimeUtils.formatTimeStamp(wait.updated), numericDates: false)
                waitCell.updatedLabel.text = updated
            } catch TimeUtils.TimeUtilsError.invalidTimeString {
                waitCell.updatedLabel.text = "N/A"
            } catch {
                waitCell.updatedLabel.text = "N/A"
            }
        
            if wait.waitTime == -1 {
                waitCell.waitTimeLabel.text = "N/A"
            }else if wait.waitTime < 5 {
                waitCell.waitTimeLabel.text = "< 5 min"
            }else{
                waitCell.waitTimeLabel.text = String(wait.waitTime) + " min"
            }
        
            // set up favorite button
            waitCell.favoriteButton.isHidden = true
        
            waitCell.RouteImage.image = UIHelpers.getRouteIconFor(borderWait: wait)
        
            return waitCell
        
        case .route:
        
            let routeCell = tableView.dequeueReusableCell(withIdentifier: myRouteCellIdentifier, for: indexPath) as! MyRouteFavoritesCell
            
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
        
        let renameLocationAction = UITableViewRowAction(style: UITableViewRowAction.Style.normal, title: "Edit", handler: { (action:UITableViewRowAction,
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
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Remove" , handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
        
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
            case .tollRate:
                TollRateSignsStore.updateFavorite(self.tollRates[indexPath.row], newValue: false)
                self.tollRates.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            case .route:
                _ = MyRouteStore.updateSelected(self.myRoutes[indexPath.row], newValue: false)
                self.myRoutes.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                break
            case .borderWait:
                BorderWaitStore.updateFavorite(self.borderWaits[indexPath.row], newValue: false)
                self.borderWaits.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
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
        case .tollRate:
            break
        case .borderWait:
            break
        case .route:
            performSegue(withIdentifier: segueMyRouteReportViewController, sender: nil)
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
       
        if segue.identifier == segueMyRouteReportViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationViewController = segue.destination as! MyRouteReportViewController
                destinationViewController.title = myRoutes[indexPath.row].name
                destinationViewController.route = myRoutes[indexPath.row]
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
                let destinationViewController = segue.destination as! RouteDeparturesViewController
                destinationViewController.title = routeItem.routeDescription
                destinationViewController.routeItem = routeItem
                destinationViewController.routeId = routeItem.routeId
            }
        }
        
        if segue.identifier == segueRouteAlertsViewController {
            if let alertButton = sender as? UIButton {
                let routeItem = self.ferrySchedules[alertButton.tag] as FerryScheduleItem
                let destinationViewController = segue.destination as! RouteAlertsViewController
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

extension FavoritesHomeViewController {
    
    /**
     * Method name: openAlerts
     * Description: called when user taps an alert button on a route cell.
     */
    @objc func openFerryAlerts(sender: UIButton) {
        performSegue(withIdentifier: segueRouteAlertsViewController, sender: sender)
    }
    
}
