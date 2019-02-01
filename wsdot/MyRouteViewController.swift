//
//  MyRouteViewController.swift
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

class MyRouteViewController: UIViewController {

    let segueNewRouteViewController = "RouteSetupViewController"
    let segueMyRouteAlertsViewController = "MyRouteAlertsViewController"
    
    let routeCellIdentifier = "RouteCell"
    
    var myRoutes = MyRouteStore.getRoutes()
    var loadingRouteAlert = UIAlertController()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newRouteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        myRoutes = MyRouteStore.getRoutes()
        
        if myRoutes.count == 0 {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
        }
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "MyRoutes")
        
        /*
        // Check if user has added a new route, and requested app favorites items on route
        for route in myRoutes {
            if !route.foundCameras || !route.foundTravelTimes {
                
                self.showRouteOverlay()
                
                let serviceGroup = DispatchGroup();
                
                if !route.foundCameras { requestCamerasUpdate(true, serviceGroup: serviceGroup) }
                if !route.foundTravelTimes { requestTravelTimesUpdate(true, serviceGroup: serviceGroup) }
        
                serviceGroup.notify(queue: DispatchQueue.main) {
                    
                    if !route.foundCameras { _ = MyRouteStore.selectNearbyCameras(forRoute: route) }
                    if !route.foundTravelTimes { _ = MyRouteStore.selectNearbyTravelTimes(forRoute: route) }
         
         // TODO: make new helper for just cameras and travel times
                    _ = MyRouteStore.updateFindNearby(forRoute: route, foundCameras: true, foundTimes: true, foundFerries: true, foundPasses: true)
                    
                    // dismiss the routeLoadingOverlay
                    self.loadingRouteAlert.dismiss(animated: true, completion: nil)
                }
            }
        }
         */

    }

    @IBAction func newRouteButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: segueNewRouteViewController, sender: self)
    }
    
    @IBAction func firstNewRouteButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: segueNewRouteViewController, sender: self)
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
    
    func showRouteOverlay(){
        loadingRouteAlert = UIAlertController(title: nil, message: "Please wait.\nAdding Favorites...", preferredStyle: .alert)
        loadingRouteAlert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame:CGRect(x:10, y:5, width:50, height:50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        loadingRouteAlert.view.addSubview(loadingIndicator)
        self.present(loadingRouteAlert, animated: true, completion: nil)
    }
    
    @objc func setRoute(sender: UIButton) {
        _ = MyRouteStore.updateSelected(myRoutes[sender.tag], newValue: !myRoutes[sender.tag].selected)
        tableView.reloadData()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == segueMyRouteAlertsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
            
                let destinationViewController = segue.destination as! MyRouteReportViewController
                destinationViewController.title = myRoutes[indexPath.row].name
                destinationViewController.route = myRoutes[indexPath.row]
                destinationViewController.navigationController?.navigationBar.tintColor = Colors.tintColor
            
            }
        }

    }
    
    func styleButtons() {
        newRouteButton.layer.cornerRadius = 5
        newRouteButton.clipsToBounds = true
    }
}

// MARK: - TableView

extension MyRouteViewController:  UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myRoutes.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let routeCell = tableView.dequeueReusableCell(withIdentifier: routeCellIdentifier, for: indexPath) as! MyRouteCell
            
        routeCell.titleLabel.text = myRoutes[indexPath.row].name
        
        routeCell.titleLabel.accessibilityLabel = "Route " + myRoutes[indexPath.row].name + ". Swipe right for options."
        
        if myRoutes[indexPath.row].selected {
            routeCell.setButton.setImage(UIImage(named: "icFavoriteSelected"), for: .normal)
            routeCell.setButton.accessibilityLabel = "remove from favorites"
        } else {
            routeCell.setButton.setImage(UIImage(named: "icFavoriteDefault"), for: .normal)
            routeCell.setButton.accessibilityLabel = "add to favorites"
        }
        
        routeCell.setButton.tag = indexPath.row
        routeCell.setButton.addTarget(self, action:#selector(MyRouteViewController.setRoute), for: .touchUpInside)
        
        routeCell.accessoryType = .disclosureIndicator
            
        return routeCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueMyRouteAlertsViewController, sender: self)
    }
    
}
