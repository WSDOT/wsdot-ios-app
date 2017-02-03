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

    let segueNewRouteViewController = "NewRouteViewController"
    let routeCellIdentifier = "RouteCell"
    
    var myRoutes = MyRouteStore.getRoutes()

    var loadingRouteAlert = UIAlertController()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        myRoutes = MyRouteStore.getRoutes()
        tableView.reloadData()

        // Check if user has added a new route, and requested app favorites items on route
        for route in myRoutes {
            if !route.hasFoundNearbyItems {
                
                showRouteOverlay()
                
                let serviceGroup = DispatchGroup();
                
                requestFerriesUpdate(true, serviceGroup: serviceGroup)
                requestCamerasUpdate(true, serviceGroup: serviceGroup)
                requestTravelTimesUpdate(true, serviceGroup: serviceGroup)
                requestMountainPassesUpdate(true, serviceGroup: serviceGroup)
                
                serviceGroup.notify(queue: DispatchQueue.main) {
                    
                    _ = MyRouteStore.selectNearbyCameras(forRoute: route)
                    _ = MyRouteStore.selectNearbyTravelTimes(forRoute: route)
                    _ = MyRouteStore.selectNearbyFerries(forRoute: route)
                    _ = MyRouteStore.selectNearbyPasses(forRoute: route)
                    
                    _ = MyRouteStore.updateFindNearby(forRoute: route, withValue: true)
                    
                    // dismiss the routeLoadingOverlay
                    self.loadingRouteAlert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func newRouteButtonPressed(_ sender: UIBarButtonItem) {
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
        loadingRouteAlert = UIAlertController(title: nil, message: "Finding Favorites...", preferredStyle: .alert)
        loadingRouteAlert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame:CGRect(x:10, y:5, width:50, height:50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        loadingRouteAlert.view.addSubview(loadingIndicator)
        self.present(loadingRouteAlert, animated: true, completion: nil)
    }
    
    func setRoute(sender: UIButton) {
        _ = MyRouteStore.updateSelected(myRoutes[sender.tag], newValue: true)
        tableView.reloadData()
    }
    
    func editRoute(sender: UIButton){
    
        let editController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        editController.view.tintColor = Colors.tintColor
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (result : UIAlertAction) -> Void in
            //action when pressed button
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (result : UIAlertAction) -> Void in
            let alertController = UIAlertController(title: "Are you sure you want to delete this route?", message:"This cannot be undone.", preferredStyle: .alert)

            alertController.view.tintColor = Colors.tintColor

            let confirmDeleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) -> Void in
                _ = MyRouteStore.delete(route: self.myRoutes.remove(at: sender.tag))
                self.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(confirmDeleteAction)
            
            self.present(alertController, animated: false, completion: nil)
        }
        
        let renameAction = UIAlertAction(title: "Rename", style: .default) { (result : UIAlertAction) -> Void in
        
            let alertController = UIAlertController(title: "New Name", message:nil, preferredStyle: .alert)
            alertController.addTextField { (textfield) in
                textfield.placeholder = self.myRoutes[sender.tag].name
            }
            alertController.view.tintColor = Colors.tintColor

            let okAction = UIAlertAction(title: "Ok", style: .default) { (_) -> Void in
        
                let textf = alertController.textFields![0] as UITextField
                var name = textf.text!
                if name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
                    name = self.myRoutes[sender.tag].name
                }
                _ = MyRouteStore.updateName(forRoute: self.myRoutes[sender.tag], name)
                self.tableView.reloadData()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: false, completion: nil)
        }
        
        // TODO: Add reload favorites action
        let reloadAction = UIAlertAction(title: "Find Favorites", style: .default) { (result : UIAlertAction) -> Void in
            
            let alertController = UIAlertController(title: "Check for favorites on this route?", message:nil, preferredStyle: .alert)
            alertController.view.tintColor = Colors.tintColor

            let okAction = UIAlertAction(title: "Yes", style: .default) { (_) -> Void in
                
                self.showRouteOverlay()
                
                let serviceGroup = DispatchGroup();
                
                self.requestFerriesUpdate(true, serviceGroup: serviceGroup)
                self.requestCamerasUpdate(true, serviceGroup: serviceGroup)
                self.requestTravelTimesUpdate(true, serviceGroup: serviceGroup)
                self.requestMountainPassesUpdate(true, serviceGroup: serviceGroup)
                
                serviceGroup.notify(queue: DispatchQueue.main) {
                    
                    _ = MyRouteStore.selectNearbyCameras(forRoute: self.myRoutes[sender.tag])
                    _ = MyRouteStore.selectNearbyTravelTimes(forRoute: self.myRoutes[sender.tag])
                    _ = MyRouteStore.selectNearbyFerries(forRoute: self.myRoutes[sender.tag])
                    _ = MyRouteStore.selectNearbyPasses(forRoute: self.myRoutes[sender.tag])
                    
                    _ = MyRouteStore.updateFindNearby(forRoute: self.myRoutes[sender.tag], withValue: true)
                    
                    // dismiss the routeLoadingOverlay
                    self.loadingRouteAlert.dismiss(animated: true, completion: nil)
                }

                self.tableView.reloadData()
            }
            
            let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: false, completion: nil)


        }
        
        editController.addAction(cancelAction)
        editController.addAction(reloadAction)
        editController.addAction(renameAction)
        editController.addAction(deleteAction)
  
    
        self.present(editController, animated: true, completion: nil)

    }
}

// MARK: - TableView

extension MyRouteViewController:  UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myRoutes.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let routeCell = tableView.dequeueReusableCell(withIdentifier: routeCellIdentifier, for: indexPath) as! MyRouteSettingsCell
            
        routeCell.titleLabel.text = myRoutes[indexPath.row].name
        
        if myRoutes[indexPath.row].selected {
            routeCell.setButton.setImage(UIImage(named: "icFavoriteSelected"), for: .normal)
        } else {
            routeCell.setButton.setImage(UIImage(named: "icFavoriteDefault"), for: .normal)
        }
            
        routeCell.setButton.tag = indexPath.row
        routeCell.setButton.addTarget(self, action:#selector(MyRouteViewController.setRoute), for: .touchUpInside)
            
        routeCell.editButton.tag = indexPath.row
        routeCell.editButton.addTarget(self, action:#selector(MyRouteViewController.editRoute), for: .touchUpInside)
            
        return routeCell
  
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section){
        case 1:
            _ = MyRouteStore.updateSelected(myRoutes[indexPath.row], newValue: !myRoutes[indexPath.row].selected)
            tableView.reloadData()
            tableView.deselectRow(at: indexPath, animated: true)
            break
        default:
            break
        }
    }
    
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
}

