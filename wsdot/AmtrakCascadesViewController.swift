//
//  AmtrakCascadesViewController.swift
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

class AmtrakCascadesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    let cellIdentifier = "AmtrakCell"
    let segueAmtrakSchedulesViewController = "AmtrakCascadesScheduleViewController"

    let menu_options = ["Buy Tickets on Amtrak.com", "Check Schedules and Status"]

    override func viewDidLoad() {
    super.viewDidLoad()
        title = "Amtrak Cascades"

    }

    override func viewWillAppear(animated: Bool) {
        GoogleAnalytics.screenView("/Amtrak Cascades")
    }

    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        cell.textLabel?.text = menu_options[indexPath.row]
     
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Perform Segue
        switch (indexPath.row) {
        case 0:
            GoogleAnalytics.screenView("/Amtrak Cascades/Buy Tickets")
            UIApplication.sharedApplication().openURL(NSURL(string: "http://m.amtrak.com")!)
            break
        case 1:
            performSegueWithIdentifier(segueAmtrakSchedulesViewController, sender: self)
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}