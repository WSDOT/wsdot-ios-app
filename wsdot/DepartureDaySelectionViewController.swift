//
//  DepartureDaySelectionViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 9/8/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class DepartureDaySelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "dayCell"

    var my_parent: RouteTimesViewController? = nil

    var menu_options: [String] = []
    var selectedIndex = 0
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {()->Void in});
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
        my_parent!.daySelected(indexPath.row)
        self.dismiss(animated: true, completion: {()->Void in});
    }
}

