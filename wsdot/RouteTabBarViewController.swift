//
//  RouteTabViewController.swift
//  WSDOT
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

/*
 Modified UITabBarController with routeItem data to be accessed by child views,
 holds controller logic for adding route to favorites.
 */
class RouteTabBarViewController: UITabBarController {
    
    var routeItem: FerryScheduleItem?
    var routeId: Int = 0
    
    var selectedTab: Int = 0

    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()

    let favoriteBarButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.favoriteBarButton.action = #selector(RouteTabBarViewController.updateFavorite(_:))
        self.favoriteBarButton.target = self
        self.favoriteBarButton.tintColor = Colors.yellow
        self.favoriteBarButton.image = UIImage(named: "icStarSmall")
        self.favoriteBarButton.accessibilityLabel = "add to favorites"

        self.navigationItem.rightBarButtonItem = self.favoriteBarButton
        
        loadSailings()
    }
    
    func loadSailings(){
    
        self.showOverlay(self.view)
    
        FerryRealmStore.updateRouteSchedules(false, completion: { error in
            if (error == nil) {
                
                self.routeItem = FerryRealmStore.findSchedule(withId: self.routeId)

                if let routeItemValue = self.routeItem {
                    self.title = routeItemValue.routeDescription

                    if (routeItemValue.routeAlerts.count > 0){
                        self.tabBar.items?[1].badgeValue = String(routeItemValue.routeAlerts.count)
                    } else {
                        self.tabBar.items?[1].isEnabled = false
                    }
        
                    if (routeItemValue.selected){
                        self.favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
                        self.favoriteBarButton.accessibilityLabel = "remove from favorites"
                    }else{
                        self.favoriteBarButton.image = UIImage(named: "icStarSmall")
                        self.favoriteBarButton.accessibilityLabel = "add to favorites"
                    }
                
                    let sailings = self.children[0] as! RouteSailingsViewController
                    sailings.setRouteItemAndReload(routeItemValue)
                
                    let alerts = self.children[1] as! RouteAlertsViewController
                    alerts.setAlertsFromRouteItem(routeItemValue)
                
                    self.pushAlertCheck(routeItemValue)
                    
                    self.hideOverlayView()
                } else {
        
                    self.navigationItem.rightBarButtonItem = nil
                    self.hideOverlayView()
                    
                    let alert = AlertMessages.getSingleActionAlert("Route Unavailable", message: "", confirm: "OK", comfirmHandler: { action in
                        self.navigationController!.popViewController(animated: true)
                    })
                
                    self.present(alert, animated: true, completion: nil)
                    
                }
            } else {
                self.hideOverlayView()
                self.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
            }
        })
    }
    
    func pushAlertCheck(_ routeItem: FerryScheduleItem){
        if self.selectedTab == 1 && routeItem.routeAlerts.count != 0 {
            self.selectedIndex = self.selectedTab
        } else if self.selectedTab == 1 && routeItem.routeAlerts.count == 0 {
            self.present(AlertMessages.getAlert("Alert Unavailable", message: "Sorry, this alert has expired", confirm: "OK"), animated: false)
        }
    }
    
    func showOverlay(_ view: UIView) {
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.style = .whiteLarge
        activityIndicator.color = UIColor.gray
        
        if self.splitViewController!.isCollapsed {
            activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        } else {
            activityIndicator.center = CGPoint(x: view.center.x - self.splitViewController!.viewControllers[0].view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        }
        
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    func hideOverlayView(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    @objc func updateFavorite(_ sender: UIBarButtonItem) {
        if let routeItemValue = routeItem {
            if (routeItemValue.selected){
                FerryRealmStore.updateFavorite(routeItemValue, newValue: false)
                favoriteBarButton.image = UIImage(named: "icStarSmall")
                favoriteBarButton.accessibilityLabel = "add to favorites"
            }else {
                FerryRealmStore.updateFavorite(routeItemValue, newValue: true)
                favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
                favoriteBarButton.accessibilityLabel = "remove from favorites"
            }
        }
    }
}
