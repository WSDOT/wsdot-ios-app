//
//  FavoritesViewController.swift
//  wsdot
//
//  Created by Logan Sims on 6/29/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let TITLE = "Favorites"

    let ferriesCellIdentifier = "FerriesFavoriteCell"

    @IBOutlet weak var favoritesTable: UITableView!

    var favoriteRoutes = [FerriesRouteScheduleItem]()
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = TITLE
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(FavoritesViewController.loadFavorites), forControlEvents: .ValueChanged)
        refreshControl.attributedTitle = NSAttributedString.init(string: "loading favorites")
        favoritesTable.addSubview(refreshControl)
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.refreshControl.beginRefreshing()
        self.loadFavorites()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Initialize Tab Bar Item
        tabBarItem = UITabBarItem(title: TITLE, image: UIImage(named: "ic-star"), tag: 1)
    }
    
    @objc private func loadFavorites(){
        
        let serviceGroup = dispatch_group_create();
        self.requestFavoriteFerries(serviceGroup)
        
        dispatch_group_notify(serviceGroup, dispatch_get_main_queue()) { // 2
            self.favoritesTable.reloadData()
            self.refreshControl.endRefreshing()
        }
        
    }
    
    private func requestFavoriteFerries(serviceGroup: dispatch_group_t){
        // Dispatch work with QOS user initated for top priority.
        // weak binding in case user navigates away and self becomes nil.
        dispatch_group_enter(serviceGroup)
        
        RouteSchedulesStore.getRouteSchedules(false, favoritesOnly: false, completion: { data, error in
            if let validData = data {
                self.favoriteRoutes.removeAll()
                for route in validData {
                    if (route.selected){
                        self.favoriteRoutes.append(route)
                    }
                }
                dispatch_group_leave(serviceGroup)
            } else {
                dispatch_group_leave(serviceGroup)
                self.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
            }
        })
    }



    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch(section){
        case 0:
            if self.favoriteRoutes.count > 0 {
                return "Ferry Schedules"
            }
            return nil
         default:
            return nil
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch(section){
            
        case 0:
            return favoriteRoutes.count
            
            
        default:
            return 0
            
        }
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch(indexPath.section){
            
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(ferriesCellIdentifier) as! RoutesCustomCell
            
            cell.title.text = favoriteRoutes[indexPath.row].routeDescription
            
            if self.favoriteRoutes[indexPath.row].crossingTime != nil {
                cell.subTitleOne.hidden = false
                cell.subTitleOne.text = "Crossing time: ~ " + self.favoriteRoutes[indexPath.row].crossingTime! + " min"
            } else {
                cell.subTitleOne.hidden = true
            }
            
            cell.subTitleTwo.text = TimeUtils.timeSinceDate(self.favoriteRoutes[indexPath.row].cacheDate, numericDates: true)
            
            return cell
            
        default:
            return tableView.dequeueReusableCellWithIdentifier("", forIndexPath: indexPath)

        }
        

        

    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
