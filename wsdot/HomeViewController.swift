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
    
    let SegueEventViewController = "EventViewController"
    
    var menu_options: [String] = []
    var menu_icon_names: [String] = []
    
    var eventBannerView = UIView()
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Title
        title = "WSDOT"
        
        menu_options = ["Traffic Map", "Ferries", "Mountain Passes", "Toll Rates", "Border Waits", "Amtrak Cascades", "My Routes", "Favorites"]
        menu_icon_names = ["icHomeTraffic","icHomeFerries","icHomePasses","icHomeTollRates","icHomeBorderWaits","icHomeAmtrakCascades", "icHomeMyRoutes", "icHomeFavorites"]

        let image : UIImage = UIImage(named: "wsdot_banner.png")!
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        if (self.splitViewController!.viewControllers.count > 1){
            let navController = self.splitViewController!.viewControllers[1] as! UINavigationController
            navController.viewControllers[0].navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            navController.viewControllers[0].navigationItem.leftItemsSupplementBackButton = true
        }
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            EventStore.fetchAndSaveEventItem()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        displayEventBannerIfNeeded()
    }
    
    /**
     *  Checks if there is an active event and creates an event banner if so.
     */
    private func displayEventBannerIfNeeded(){
        
        guard let eventItem = EventStore.getActiveEvent() else { return }
       
        if eventItem.themeId == ThemeManager.currentTheme().rawValue {

            // clear any old event banner (Probably from screen rotation)
            eventBannerView.removeFromSuperview()
            
            // create the event banner view
            eventBannerView = UIView(frame: .zero)
            eventBannerView.frame.size = CGSize(width: self.view.frame.width, height: 36)
            eventBannerView.frame.origin = CGPoint(x: 0, y: 0)
            eventBannerView.backgroundColor = Colors.lightGrey
            
            // get the accessory icon
            let iconView = UIImageView(image: UIImage(named: "icOpen"))
            
            // Create banner label with text from the eventItem. Set frame to fill banner view with room for the accessory icon
            let label = UILabel(frame: eventBannerView.frame)
            label.frame.origin = CGPoint(x: 8, y: 0)
            label.frame.size = CGSize(width: eventBannerView.frame.width - iconView.frame.width - 8, height: eventBannerView.frame.height)
            label.textAlignment = .center
            label.textColor = ThemeManager.currentTheme().darkColor
            label.font = UIFont(name: label.font.fontName, size: 14)
            label.text = eventItem.bannerText
            
            // position the iconView on the right side of the event banner
            iconView.frame.origin = CGPoint(x: label.frame.width, y: (eventBannerView.frame.height - iconView.frame.height) / 2)
            
            // Add subviews to the event banner
            eventBannerView.addSubview(label)
            eventBannerView.addSubview(iconView)
            
            // Add a tap recongnizer to the event banner
            let tap = UITapGestureRecognizer(target: self, action:  #selector (self.eventBannerTap(_:)))
            eventBannerView.addGestureRecognizer(tap)
            
            // add the event banner to the main view
            self.view!.addSubview(eventBannerView)

            // Adjust the tableviw's content inset to make room for the event banner
            tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            tableView.contentInset = UIEdgeInsetsMake(tableView.contentInset.top + eventBannerView.frame.height, tableView.contentInset.left, tableView.contentInset.bottom, tableView.contentInset.right)
            
            // reset tableview scroll position
            tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated:false)

        }
    }
    
    func eventBannerTap(_ sender:UITapGestureRecognizer) {
        selectedIndex = -1
        performSegue(withIdentifier: SegueEventViewController, sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Home")
        displayEventBannerIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        eventBannerView.removeFromSuperview()
    }

    @IBAction func infoBarButtonPressed(_ sender: UIBarButtonItem) {
        selectedIndex = -1
        performSegue(withIdentifier: SegueInfoViewController, sender: self)
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
        
        if menu_icon_names.indices.contains(indexPath.row) {
            cell.iconView.image = UIImage(named: menu_icon_names[indexPath.row])
        }
        
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
                performSegue(withIdentifier: segueMyRouteViewController, sender: self)
                break
            case 7:
                performSegue(withIdentifier: SegueFavoritesViewController, sender: self)
            default:
                break
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.destination is UINavigationController {
            let destinationViewController = segue.destination as! UINavigationController
            
            destinationViewController.viewControllers[0].navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            destinationViewController.viewControllers[0].navigationItem.leftItemsSupplementBackButton = true
        }
    }
}
