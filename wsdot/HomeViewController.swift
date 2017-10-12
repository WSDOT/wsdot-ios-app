//
//  HomeViewController.swift
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
import EasyTipView

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier = "HomeCell"
    
    let SegueFavoritesViewController = "FavoritesViewController"
    
    let SegueTrafficMapViewController = "TrafficMapViewController"
    let SegueFerriesHomeViewController = "FerriesHomeViewController"
    let SegueTollRatesViewController = "TollRatesViewController"
    let SegueBorderWaitsViewController = "BorderWaitsViewController"
    let SegueInfoViewController = "InfoViewController"
    let SegueMountainPassesViewController = "MountainPassesViewController"
    let SegueAmtrakCascadesViewController = "AmtrakCascadesViewController"
    let segueMyRouteViewController = "MyRouteViewController"
    
    var tipView = EasyTipView(text: "")
    
    var menu_options: [String] = []
    var menu_icon_names: [String] = []

    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndex = 0

    @IBOutlet weak var myRouteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Title
        title = "WSDOT"
        
        menu_options = ["Traffic Map", "Ferries", "Mountain Passes", "Toll Rates", "Border Waits", "Amtrak Cascades", "Favorites"]
        menu_icon_names = ["icHomeTraffic","icHomeFerries","icHomePasses","icHomeTollRates","icHomeBorderWaits","icHomeAmtrakCascades", "icHomeFavorites"]
        
        if (self.splitViewController!.viewControllers.count > 1){
            let navController = self.splitViewController!.viewControllers[1] as! UINavigationController
            navController.viewControllers[0].navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            navController.viewControllers[0].navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Home")
        tableView.deselectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false)
        
        if (self.splitViewController!.viewControllers.count > 1){
            tableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .none)
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if (self.splitViewController!.viewControllers.count == 1){
            tableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false)
        }
        
    }
 
    @IBAction func infoBarButtonPressed(_ sender: UIBarButtonItem) {
        tableView.deselectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false)
        performSegue(withIdentifier: SegueInfoViewController, sender: self)
    }
    
    @IBAction func myRouteButtonPressed(_ sender: UIBarButtonItem) {
        tipView.dismiss()
        tableView.deselectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false)
        performSegue(withIdentifier: segueMyRouteViewController, sender: self)
    }
    
    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! IconCell
        
        cell.label?.text = menu_options[indexPath.row]
        cell.iconView.image = UIImage(named: menu_icon_names[indexPath.row])
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform Segue if the view controller isn't already displayed.
        // If it is, pop the naviagtion stack to return to the first view.
        if (selectedIndex == indexPath.row && self.splitViewController!.viewControllers.count > 1) {
            let navController = self.splitViewController?.viewControllers[1] as! UINavigationController
            navController.popToRootViewController(animated: true)
        } else {
        
            selectedIndex = indexPath.row
        
            switch (indexPath.row) {
            case 0:
                performSegue(withIdentifier: SegueTrafficMapViewController, sender: self)
                break
            case 1:
                performSegue(withIdentifier: SegueFerriesHomeViewController, sender: self)
                break
            case 2:
                performSegue(withIdentifier: SegueMountainPassesViewController, sender: self)
                break
            case 3:
                performSegue(withIdentifier: SegueTollRatesViewController, sender: self)
                break
            case 4:
                performSegue(withIdentifier: SegueBorderWaitsViewController, sender: self)
                break
            case 5:
                performSegue(withIdentifier: SegueAmtrakCascadesViewController, sender: self)
                break
            case 6:
                performSegue(withIdentifier: SegueFavoritesViewController, sender: self)
            default:
                break
            }
        }
        
        //tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.destination is UINavigationController {
            let destinationViewController = segue.destination as! UINavigationController
            
            destinationViewController.navigationBar.isTranslucent = true
            destinationViewController.navigationBar.tintColor = UIColor.white
            destinationViewController.navigationBar.color
            
            destinationViewController.viewControllers[0].navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            destinationViewController.viewControllers[0].navigationItem.leftItemsSupplementBackButton = true
        }
    }
}

extension HomeViewController: EasyTipViewDelegate {
    
    public func easyTipViewDidDismiss(_ tipView: EasyTipView) {
         UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSeenMyRouteTipView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tipView.dismiss()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if (!UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSeenMyRouteTipView) && !UIAccessibilityIsVoiceOverRunning()){
            tipView = EasyTipView(text: "Check for highway alerts important to you by creating your own route.", delegate: self)
            tipView.show(forItem: self.myRouteButton)
        }
    }
}
