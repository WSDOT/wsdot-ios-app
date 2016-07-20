//
//  RouteDepartureViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 7/18/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit

class RouteSailingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "RouteSailings"

    var routeItem : FerriesRouteScheduleItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sailings"
        
        self.tabBarController!.navigationItem.title = "Sailings";
        
        
        
        let favoriteButton = UIButton()
        favoriteButton.setImage(UIImage(named: "icFavoriteDefault"), forState: .Normal)
        favoriteButton.setImage(UIImage(named: "icFavoriteSelected"), forState: .Highlighted)
        favoriteButton.tintColor = UIColor.redColor()
        
        favoriteButton.addTarget(self, action: #selector(RouteSailingsViewController.addFavorite(_:)), forControlEvents: .TouchUpInside)
        favoriteButton.sizeToFit()
        
        let favoritesNavItemButton = UIBarButtonItem()
        favoritesNavItemButton.target = self
        favoritesNavItemButton.action = #selector(RouteSailingsViewController.addFavorite(_:))
        favoritesNavItemButton.customView = favoriteButton
        
        self.tabBarController!.navigationItem.rightBarButtonItem = favoritesNavItemButton
        
    }
    
    func addFavorite(sender: UIButton){
        
        sender.setImage(UIImage(named: "icFavoriteSelected"), forState: .Normal)
        sender.setImage(UIImage(named: "icFavoriteDefault"), forState: .Highlighted)
        sender.setImage(UIImage(named: "icFavoriteDefault"), forState: .Selected)
        sender.removeTarget(self, action: #selector(RouteSailingsViewController.addFavorite(_:)), forControlEvents: .TouchUpInside)
        sender.addTarget(self, action: #selector(RouteSailingsViewController.removeFavorite(_:)), forControlEvents: .TouchUpInside)
        
        print("fav Added!")
        
    }
    
    func removeFavorite(sender: UIButton){
        sender.setImage(UIImage(named: "icFavoriteDefault"), forState: .Normal)
        sender.setImage(UIImage(named: "icFavoriteSelected"), forState: .Highlighted)
        sender.setImage(UIImage(named: "icFavoriteSelected"), forState: .Selected)
        sender.removeTarget(self, action: #selector(RouteSailingsViewController.removeFavorite(_:)), forControlEvents: .TouchUpInside)
        sender.addTarget(self, action: #selector(RouteSailingsViewController.addFavorite(_:)), forControlEvents: .TouchUpInside)
        
        

        print("fav removed!")
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (routeItem?.sailings.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        cell.textLabel?.text = routeItem?.sailings[indexPath.row]
        
        return cell
    }
    
    
    
    
    
}
