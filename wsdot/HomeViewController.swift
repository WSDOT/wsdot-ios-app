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

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EasyTipViewDelegate {
    
    let cellIdentifier = "HomeCell"
    
    let SegueTrafficMapViewController = "TrafficMapViewController"
    let SegueFerriesHomeViewController = "FerriesHomeViewController"
    let SegueTollRatesViewController = "TollRatesViewController"
    let SegueBorderWaitsViewController = "BorderWaitsViewController"
    let SegueInfoViewController = "InfoViewController"
    let SegueSettingsViewController = "SettingsViewController"
    let SegueMountainPassesViewController = "MountainPassesViewController"
    let SegueSocialMediaViewController = "SocialMediaViewController"
    let SegueAmtrakCascadesViewController = "AmtrakCascadesViewController"
    let SegueFavoritesViewController = "FavoritesViewController"
    
    var menu_options: [String] = []
    var menu_icon_names: [String] = []
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    var tipView: EasyTipView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Title
        title = "WSDOT"
        
        menu_options = ["Traffic Map", "Ferries", "Mountain Passes", "Social Media", "Toll Rates", "Border Waits", "Amtrak Cascades", "Favorites"]
        menu_icon_names = ["icHomeTraffic","icHomeFerries","icHomePasses","icHomeSocialMedia","icHomeTollRates","icHomeBorderWaits","icHomeAmtrakCascades", "icHomeFavorites"]
        
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        self.navigationController!.navigationBar.tintColor = Colors.tintColor
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Home")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
         // Check UserDefaults to see if they have seen the tooltip before. Display if they haven't
        let hasSeenNotificationTip = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSeenNotificationTip)
        if (!hasSeenNotificationTip){
            // Setup easy tip
            var preferences = EasyTipView.Preferences()
            preferences.drawing.font = UIFont(name: "Arial", size: 13)!
            preferences.drawing.foregroundColor = UIColor.white
            preferences.drawing.backgroundColor = UIColor(hue: 0.4639, saturation: 1, brightness: 0.47, alpha: 1.0) /* #00795f */
            preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        
            tipView = EasyTipView(text: "Turn on notifications to receive alerts about major statewide traffic incidents.", preferences: preferences, delegate: self)
            tipView!.show(forItem: self.settingsButton, withinSuperView: self.navigationController?.view)
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSeenNotificationTip)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (tipView != nil){
            tipView!.dismiss()
        }
    }
 
    @IBAction func infoBarButtonPressed(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let infoViewController = storyboard.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController
        infoViewController!.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        infoViewController!.navigationItem.leftItemsSupplementBackButton = true
        infoViewController!.navigationItem.title = "Settings"
        
        showDetailViewController(infoViewController!, sender: self)
    }
    
    @IBAction func settingsBarButtonPressed(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController
        settingsViewController!.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        settingsViewController!.navigationItem.leftItemsSupplementBackButton = true
        settingsViewController!.navigationItem.title = "Settings"
        
        showDetailViewController(settingsViewController!, sender: self)
    
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

        // Perform Segue
        switch (indexPath.row) {
        case 0:
            performSegue(withIdentifier: SegueTrafficMapViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 1:
            performSegue(withIdentifier: SegueFerriesHomeViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 2:
            performSegue(withIdentifier: SegueMountainPassesViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 3:
            performSegue(withIdentifier: SegueSocialMediaViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 4:
            performSegue(withIdentifier: SegueTollRatesViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 5:
            performSegue(withIdentifier: SegueBorderWaitsViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 6:
            performSegue(withIdentifier: SegueAmtrakCascadesViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
            break
        case 7:
            performSegue(withIdentifier: SegueFavoritesViewController, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            break
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is UINavigationController {
            let destinationViewController = segue.destination as! UINavigationController
            destinationViewController.navigationBar.isTranslucent = false
            destinationViewController.navigationBar.barTintColor = UIColor.white
            destinationViewController.navigationBar.tintColor = Colors.tintColor
            
            if segue.identifier == SegueTrafficMapViewController {
                let storyboard = UIStoryboard(name: "TrafficMap", bundle: nil)
                let trafficMapViewController = storyboard.instantiateViewController(withIdentifier: "TrafficMapViewController") as? TrafficMapViewController
                trafficMapViewController!.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                trafficMapViewController!.navigationItem.leftItemsSupplementBackButton = true
                trafficMapViewController!.navigationItem.title = "Traffic Map"
                if !destinationViewController.viewControllers.contains(trafficMapViewController!){
                    destinationViewController.pushViewController(trafficMapViewController!, animated: true)
                }
            }
            
            if segue.identifier == SegueFerriesHomeViewController {
                let storyboard = UIStoryboard(name: "Ferries", bundle: nil)
                let ferriesHomeViewController = storyboard.instantiateViewController(withIdentifier: "FerriesHomeViewController") as? FerriesHomeViewController
                ferriesHomeViewController!.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                ferriesHomeViewController!.navigationItem.leftItemsSupplementBackButton = true
                ferriesHomeViewController!.navigationItem.title = "Ferries"
                if !destinationViewController.viewControllers.contains(ferriesHomeViewController!){
                    destinationViewController.pushViewController(ferriesHomeViewController!, animated: true)
                }
            }
            
            if segue.identifier == SegueFavoritesViewController {
                destinationViewController.viewControllers[0].navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                destinationViewController.viewControllers[0].navigationItem.leftItemsSupplementBackButton = true
            }
            
            if segue.identifier == SegueMountainPassesViewController {
                let storyboard = UIStoryboard(name: "MountainPasses", bundle: nil)
                let mountainPassesViewController = storyboard.instantiateViewController(withIdentifier: "MountainPassesViewController") as? MountainPassesViewController
                mountainPassesViewController!.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                mountainPassesViewController!.navigationItem.leftItemsSupplementBackButton = true
                mountainPassesViewController!.navigationItem.title = "Mountain Passes"
                if !destinationViewController.viewControllers.contains(mountainPassesViewController!){
                    destinationViewController.pushViewController(mountainPassesViewController!, animated: true)
                }
            }
            
            if segue.identifier == SegueSocialMediaViewController {
                let storyboard = UIStoryboard(name: "SocialMedia", bundle: nil)
                let socialMediaViewController = storyboard.instantiateViewController(withIdentifier: "SocialMediaViewController") as? SocialMediaViewController
                socialMediaViewController!.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                socialMediaViewController!.navigationItem.leftItemsSupplementBackButton = true
                socialMediaViewController!.navigationItem.title = "Social Media"
                if !destinationViewController.viewControllers.contains(socialMediaViewController!) {
                    destinationViewController.pushViewController(socialMediaViewController!, animated: true)
                }
            }
            
            if segue.identifier == SegueTollRatesViewController {
                let storyboard = UIStoryboard(name: "TollRates", bundle: nil)
                let tollRatesViewController = storyboard.instantiateViewController(withIdentifier: "TollRatesViewController") as? TollRatesViewController
                tollRatesViewController!.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                tollRatesViewController!.navigationItem.leftItemsSupplementBackButton = true
                tollRatesViewController!.navigationItem.title = "Toll Rates"
                if !destinationViewController.viewControllers.contains(tollRatesViewController!) {
                    destinationViewController.pushViewController(tollRatesViewController!, animated: true)
                }
            }
            
            if segue.identifier == SegueBorderWaitsViewController {
                let storyboard = UIStoryboard(name: "BorderWaits", bundle: nil)
                let borderWaitsViewController = storyboard.instantiateViewController(withIdentifier: "BorderWaitsViewController") as? BorderWaitsViewController
                destinationViewController.viewControllers = [borderWaitsViewController!]
                borderWaitsViewController!.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                borderWaitsViewController!.navigationItem.leftItemsSupplementBackButton = true
                borderWaitsViewController!.navigationItem.title = "Border Waits"
                if !destinationViewController.viewControllers.contains(borderWaitsViewController!) {
                    destinationViewController.pushViewController(borderWaitsViewController!, animated: true)
                }
            }
            
            if segue.identifier == SegueAmtrakCascadesViewController {
                let storyboard = UIStoryboard(name: "AmtrakCascades", bundle: nil)
                let amtrakCascadesViewController = storyboard.instantiateViewController(withIdentifier: "AmtrakCascadesViewController") as? AmtrakCascadesViewController
                destinationViewController.viewControllers = [amtrakCascadesViewController!]
                amtrakCascadesViewController!.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                amtrakCascadesViewController!.navigationItem.leftItemsSupplementBackButton = true
                amtrakCascadesViewController!.navigationItem.title = "Amtrak Cascades"
                if !destinationViewController.viewControllers.contains(amtrakCascadesViewController!) {
                    destinationViewController.pushViewController(amtrakCascadesViewController!, animated: true)
                }
            }
            
        }
    }
    
    func easyTipViewDidDismiss(_ tipView : EasyTipView){}
}
