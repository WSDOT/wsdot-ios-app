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
    
    @IBAction func infoButton(_ sender: Any) {
           
           // Ferry Schedule Calendar Message
           let alert = UIAlertController(title: "Ferry Schedule Calendar", message: "Future ferry schedules are provided for planning purposes and can change daily. Please monitor ferry alerts to stay notified of changes to your route. For additional trip planning information, visit the Washington State Ferries website.", preferredStyle: .alert);

           alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil));
           let action: UIAlertAction = UIAlertAction(title: "Ferry Website", style: .default, handler: {
              (action) in
                 UIApplication.shared.open(URL(string: "https://wsdot.wa.gov/travel/washington-state-ferries")!, options: [:], completionHandler: nil)
            })
           alert.addAction(action)
           alert.view.tintColor = Colors.tintColor
           self.present(alert, animated: true, completion: nil)
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

