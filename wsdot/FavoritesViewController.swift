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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = TITLE
        
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.requestFavoriteFerries()
        
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
    
    private func requestFavoriteFerries(){
        
        // Dispatch work with QOS user initated for top priority.
        // weak binding in case user navigates away and self becomes nil.
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            
            RouteSchedulesStore.getRouteSchedules(false, favoritesOnly: false, completion: { data, error in
                if let validData = data {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            
                            print("returned with valid data")
                            
                            for route in validData {
                                if (route.selected){
                                    print("found a favorite route")
                                    selfValue.favoriteRoutes.append(route)
                                }
                            }
                            
                            
                            selfValue.favoritesTable.reloadData()
                            //selfValue.refreshControl?.endRefreshing()
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            //selfValue.refreshControl?.endRefreshing()
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }


    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch(section){
            
        case 0:
            print(favoriteRoutes.count)
            return favoriteRoutes.count
            
            
        default:
            return 0
            
        }
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch(indexPath.section){
            
        case 0:
            print("Building ferry cell")
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
