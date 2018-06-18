//
//  I405ViewController.swift
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

import Foundation
import UIKit
import SafariServices

class I405ViewController: UIViewController, UITableViewDelegate,
UITableViewDataSource {

    let cellIdentifier = "I405TollRatesCell"

    var tollRates = [I405TollRateSignItem]()

    let refreshControl = UIRefreshControl()

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
     override func viewDidLoad() {
        super.viewDidLoad()
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(BorderWaitsViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        activityIndicator.startAnimating()
        refresh()
     
    }
    
    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        refresh()
    }
    
    func refresh(){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { [weak self] in
            TollRatesStore.getI405tollRates(completion: { data, error in
                if let validData = data {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self {
                            selfValue.tollRates = validData
                            selfValue.tableView.reloadData()
                            selfValue.tableView.reloadData()
                            selfValue.activityIndicator.stopAnimating()
                            selfValue.activityIndicator.isHidden = true
                            selfValue.refreshControl.endRefreshing()
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                        
                            selfValue.refreshControl.endRefreshing()
                            selfValue.activityIndicator.stopAnimating()
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    // MARK -- TableView delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tollRates[section].trips.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tollRates.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Entering at " + tollRates[section].startLocationName + " " + (tollRates[section].travelDirection == "N" ? "Northbound" : "Southbound")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! TollRateCell
        
        let trip = tollRates[indexPath.section].trips[indexPath.row]
        
        cell.locationLabel.text = trip.endLocationName
        cell.messageLabel.text = trip.message
        cell.rateLabel.text = "$" + String(format: "%.2f", locale: Locale.current, arguments: [trip.toll])
        cell.updatedLabel.text = TimeUtils.timeAgoSinceDate(date: trip.updatedAt, numericDates: true)
     
        return cell
        
    }
}
