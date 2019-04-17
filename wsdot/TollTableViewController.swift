//
//  SR520TollRatesViewController.swift
//  WSDOT
//
//  Copyright (c) 2018 Washington State Department of Transportation
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

class TollTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "threeColCell"

    var tollTableItem = TollRateTableItem()
    var data = [ThreeColItem]()
    
    var stateRoute: Int = 0

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tolls = TollRateTableStore.getTollRateTableByRoute(route: self.stateRoute) {
            self.tollTableItem = tolls
            self.data = self.getTollData(tolls: tolls)
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "SR520TollRates")
        
        refresh(true)
        
    }

    func refresh(_ force: Bool){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            TollRateTableStore.updateTollRateTables(force, completion: { error in
                if (error == nil) {
                
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self {
                            
                            if let tolls = TollRateTableStore.getTollRateTableByRoute(route: selfValue.stateRoute) {
                                selfValue.tollTableItem = tolls
                                selfValue.data = selfValue.getTollData(tolls: tolls)
                            }
                            
                            selfValue.tableView.reloadData()

                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self {
                           selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }

    private func getTollData(tolls: TollRateTableItem) -> [ThreeColItem] {
 
        var data = [ThreeColItem]()
                            
        for rowItem in tolls.tollTable {
            if (rowItem.rows.count == 3) {
                let item = ThreeColItem(colOne: rowItem.rows[0], colTwo: rowItem.rows[1], colThree: rowItem.rows[2], header: rowItem.header)
                    data.append(item)
            }
        }
    
        return data
    }

    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ThreeColTableCell

        cell.colOneLabel.text = data[indexPath.row].colOne
        cell.colTwoLabel.text = data[indexPath.row].colTwo
        cell.colThreeLabel.text = data[indexPath.row].colThree
        
        if (data[indexPath.row].header) {
            cell.backgroundColor = UIColor.groupTableViewBackground
        } else {
            cell.backgroundColor = UIColor.lightText
            
            // highlight current toll
            if TollRateTableStore.isTollActive(
                    startHour: tollTableItem.tollTable[indexPath.row].startHourString,
                    endHour: tollTableItem.tollTable[indexPath.row].endHourString) {
            
                let now = Date()

                if ((now.isWeekend || now.is_WAC_468_270_071_Holiday) != tollTableItem.tollTable[indexPath.row].weekday ) {
                    cell.backgroundColor = Colors.lightGreen
                }
            
            }
        }
        return cell
    }
}
