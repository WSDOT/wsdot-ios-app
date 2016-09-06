//
//  VesselWatchGoToViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/16/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//
import UIKit

class VesselWatchGoToViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let cellIdentifier = "GoToCell"
    
    var parent: VesselWatchViewController? = nil
    
    var menu_options: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        menu_options = ["Anacortes / San Juan Islands / Sidney BC",
                        "Edmonds / Kingston",
                        "Fauntleroy / Vashon / Southworth",
                        "Mukilteo / Clinton",
                        "Point Defiance / Tahlequah",
                        "Port Townsend / Coupeville",
                        "San Juan Islands Inter-Island",
                        "Seattle",
                        "Seattle / Bainbridge"]
    }

    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {()->Void in});
    }
    
    override func viewWillAppear(animated: Bool) {
        GoogleAnalytics.screenView("/Ferries/VesselWatch/GoTo Location")
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
        
        // Configure Cell
        cell.textLabel?.text = menu_options[indexPath.row]
     
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.dismissViewControllerAnimated(true, completion: {()->Void in});
        GoogleAnalytics.screenView("/Ferries/VesselWatch/GoTo Location/" + menu_options[indexPath.row])
        parent?.goTo(indexPath.row)
    }
}