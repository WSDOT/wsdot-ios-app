//
//  SailingSelectionViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 10/2/18.
//  Copyright © 2018 WSDOT. All rights reserved.

import UIKit

class TerminalSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "terminalCell"

    var my_parent: RouteDeparturesViewController? = nil

    var menu_options: [String] = []
    var selectedIndex = 0
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {()->Void in});
    }

    @IBAction func infoAction(_ sender: Any) {
        MyAnalytics.event(category: "Ferries", action: "UIAction", label: "sailings info")
        self.present(AlertMessages.getAlert("", message: "Select a departing terminal. If location services are enabled, the terminal closest to you will be automatically selected.", confirm: "OK"), animated: true)
    }
    

    override func viewDidLoad() {
        self.view.backgroundColor = ThemeManager.currentTheme().mainColor
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
        MyAnalytics.event(category: "Ferries", action: "UIAction", label: "Select Sailing")
        my_parent!.terminalSelected(indexPath.row)
        self.dismiss(animated: true, completion: {()->Void in});
    }
    
}
