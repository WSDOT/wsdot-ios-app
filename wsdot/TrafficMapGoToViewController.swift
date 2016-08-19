//
//  TrafficMapGoToViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/19/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class TrafficMapGoToViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let cellIdentifier = "GoToCell"
    
    var parent: TrafficMapViewController? = nil
    
    var menu_options: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menu_options = ["Bellingham",
                        "Chelalis",
                        "Hood Canal",
                        "Monroe",
                        "Mt Vernon",
                        "Olympia",
                        "Seattle",
                        "Snoqualmie Pass",
                        "Spokane",
                        "Stanwood",
                        "Sultan",
                        "Tacoma",
                        "Tri-Cities",
                        "Vancouver",
                        "Wenatchee",
                        "Yakima"]
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {()->Void in});
    }
    
    // MARK: -
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
    
    // MARK: -
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.dismissViewControllerAnimated(true, completion: {()->Void in});
        parent?.goTo(indexPath.row)
    }
}