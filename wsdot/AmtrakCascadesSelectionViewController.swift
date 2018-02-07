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
        case day = 0
        case origin = 1
        case destination = 2
    }

    let cellIdentifier = "cell"

    var my_parent: AmtrakCascadesScheduleViewController? = nil

    var selectionType = 0
    var menu_options: [String] = []
    var selectedIndex = 0
    var titleText = "title"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Title
        navItem.title = titleText
        
        self.view.backgroundColor = ThemeManager.currentTheme().mainColor
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {()->Void in});
    }
    
    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // Configure Cell
        cell.textLabel?.text = menu_options[indexPath.row]
     
        if (indexPath.row == selectedIndex){
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (selectionType){
        case SelectionType.day.rawValue:
            my_parent!.daySelected(indexPath.row)
            break
        case SelectionType.origin.rawValue:
            my_parent!.originSelected(indexPath.row)
            break
        case SelectionType.destination.rawValue:
            my_parent!.destinationSelected(indexPath.row)
            break
        default: break
        }
        self.dismiss(animated: true, completion: {()->Void in});
    }
}
