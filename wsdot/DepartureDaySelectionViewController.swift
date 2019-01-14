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

    let df = DateFormatter()

    var my_parent: RouteDeparturesViewController? = nil

    var date_data: [Date] = []
    var selectedIndex = 0
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {()->Void in});
    }
    
    override func viewDidLoad() {
        df.dateFormat = "MM/dd"
        self.view.backgroundColor = ThemeManager.currentTheme().mainColor
    }
    
    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return date_data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // Configure Cell
        cell.textLabel?.text = "\(TimeUtils.getDayOfWeekString(date_data[indexPath.row])) - \(df.string(from: date_data[indexPath.row]))"

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

