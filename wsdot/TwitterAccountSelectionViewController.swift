//
//  TwitterAccountSelectionViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 9/8/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//

import UIKit

class TwitterAccountSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "accountCell"

    var my_parent: TwitterViewController? = nil

    var menu_options: [String] = ["All Accounts", "Ferries", "Snoqualmie Pass", "WSDOT", "WSDOT East", "WSDOT North Traffic", "WSDOT Southwest", "WSDOT Tacoma", "WSDOT Traffic"]
    var selectedIndex = 8
    
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
        my_parent!.accountSelected(indexPath.row)
        self.dismiss(animated: true, completion: {()->Void in});
    }
}

