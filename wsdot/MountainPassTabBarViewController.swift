//
//  MountainPassDetailsViewController.swift
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
import GoogleMobileAds

class MountainPassTabBarViewController: UITabBarController{
    
    var passItem = MountainPassItem()
    
    let favoriteBarButton = UIBarButtonItem()
    var refreshBarButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = passItem.name
        
        if (passItem.forecast.count == 0){
            self.tabBar.items?[1].isEnabled = false
        }
        
        if (passItem.cameraIds.count == 0){
            self.tabBar.items?[2].isEnabled = false
        }
        
        refreshBarButton = createRefreshButton()
        
        favoriteBarButton.action = #selector(MountainPassTabBarViewController.updateFavorite(_:))
        favoriteBarButton.target = self
        favoriteBarButton.tintColor = Colors.yellow
        
        if (passItem.selected){
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
            favoriteBarButton.accessibilityLabel = "remove from favorites"
        }else{
            favoriteBarButton.image = UIImage(named: "icStarSmall")
            favoriteBarButton.accessibilityLabel = "add to favorites"
        }
        self.navigationItem.rightBarButtonItems = [favoriteBarButton, refreshBarButton]
    }
    
    @objc func updateFavorite(_ sender: UIBarButtonItem) {
        if (passItem.selected){
            MountainPassStore.updateFavorite(passItem, newValue: false)
            favoriteBarButton.image = UIImage(named: "icStarSmall")
            favoriteBarButton.accessibilityLabel = "add to favorites"
        } else {
            MountainPassStore.updateFavorite(passItem, newValue: true)
            favoriteBarButton.image = UIImage(named: "icStarSmallFilled")
            favoriteBarButton.accessibilityLabel = "remove from favorites"
        }
    }
    
    func createRefreshButton() -> UIBarButtonItem {
        let button: UIButton = UIButton(type: .system)
        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "icRefresh"), for: .normal)
        button.imageView!.tintColor = ThemeManager.currentTheme().secondaryColor
        button.addTarget(self, action: #selector(MountainPassTabBarViewController.refresh(_:)), for: .touchUpInside)

        let barButton = UIBarButtonItem(customView: button)
        barButton.accessibilityLabel = "refresh"
        
        return barButton
    }
    
    @objc func refresh(_ sender: UIBarButtonItem){
        
        refreshBarButton.customView = UIHelpers.createActivityIndicator()
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            MountainPassStore.updatePasses(true, completion: { error in
                
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            
                            selfValue.refreshBarButton = selfValue.createRefreshButton()
                            selfValue.navigationItem.rightBarButtonItems = [selfValue.favoriteBarButton, selfValue.refreshBarButton]
                            
                            if let passItem = (MountainPassStore.getPasses().filter{ $0.id == selfValue.passItem.id }.first) {
                                selfValue.passItem = passItem
                                if let reportVC = selfValue.children[0] as? MountainPassReportViewController {
                                    reportVC.updateView(withPassItem: selfValue.passItem)
                                }
                                
                                // check if the weather VC is available and update it's data.
                                if let weatherVC = selfValue.children[1] as? MountainPassWeatherViewController {
                                    weatherVC.passItem = selfValue.passItem
                                    if weatherVC.tableView != nil {
                                        weatherVC.tableView.reloadData()
                                    }
                                    
                                }
                                if let weatherVC = selfValue.children[2] as? MountainPassWeatherViewController {
                                    weatherVC.passItem = selfValue.passItem
                                    if weatherVC.tableView != nil {
                                        weatherVC.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshBarButton = selfValue.createRefreshButton()
                            selfValue.navigationItem.rightBarButtonItems = [selfValue.favoriteBarButton, selfValue.refreshBarButton]
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.passes)
                        }
                    }
                }
            })
        }
    }
}
