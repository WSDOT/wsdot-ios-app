//
//  AmtrackCascadesDaySelectionTableController.swift
//  WSDOT
//
//  Created by Logan Sims on 9/8/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class AmtrakCascadesSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navItem: UINavigationItem!
    
    enum SelectionType: Int {
        case Day = 0
        case Origin = 1
        case Destination = 2
    }

    let cellIdentifier = "cell"

    var parent: AmtrakCascadesScheduleViewController? = nil

    var selectionType = 0
    var menu_options: [String] = []
    var selectedIndex = 0
    var titleText = "title"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Title
        navItem.title = titleText
    }
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {()->Void in});
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
     
        if (indexPath.row == selectedIndex){
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (selectionType){
        case SelectionType.Day.rawValue:
            parent!.daySelected(indexPath.row)
            break
        case SelectionType.Origin.rawValue:
            parent!.originSelected(indexPath.row)
            break
        case SelectionType.Destination.rawValue:
            parent!.destinationSelected(indexPath.row)
            break
        default: break
        }
        self.dismissViewControllerAnimated(true, completion: {()->Void in});
    }
}
