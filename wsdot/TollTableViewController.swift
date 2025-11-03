//
//  TollTableViewController.swift
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

class TollTableViewController: RefreshViewController, UITableViewDelegate, UITableViewDataSource {

    let threeColCellIdentifier = "threeColCell"
    let fourColCellIdentifier = "fourColCell"
    
    var tollTableItem = TollRateTableItem()
    
    var northboundTollRates = TollRateTableItem()
    var southboundTollRates = TollRateTableItem()
    
    var stateRoute: Int = 0

    let refreshControl = UIRefreshControl()
    
    var list = [TollRateRowItem]()


    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var tollRoute: Int = 0

    @IBOutlet weak var directionSegmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showOverlay(self.view)
        
        directionSegmentControl.isHidden = true
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(TollTableViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        
        if let tolls = TollRateTableStore.getTollRateTableByRoute(route: tollRoute) {
            self.tollTableItem = tolls

        }
        
        if (self.tollRoute == 509) {
            
            if let northboundTollRates = TollRateTableStore.getTollRateTableByRoute(route: 50978) {
                self.tollTableItem = northboundTollRates
            }
            
            if let southboundTollRates = TollRateTableStore.getTollRateTableByRoute(route: 50983) {
                self.tollTableItem = southboundTollRates
            }
            
            if (directionSegmentControl.selectedSegmentIndex == 0){
                tollTableItem = northboundTollRates

            } else {
                tollTableItem = southboundTollRates
            }
            
            messageLabel.text = northboundTollRates.message

        }
        
        else if let tolls = TollRateTableStore.getTollRateTableByRoute(route: tollRoute) {
            tollTableItem = tolls
            messageLabel.text = tolls.message

        }
        
        self.edgesForExtendedLayout = []
        
        let websiteButton = UIBarButtonItem(title: "My Good To Go", style: .plain, target: self, action: #selector(goodToGoWebsite))
           navigationItem.rightBarButtonItem = websiteButton
        
        if (tollRoute == 509) {
            directionSegmentControl.isHidden = false
        }
        

    }
    
    @objc func goodToGoWebsite() {
            if let url = URL(string: "https://mygoodtogo.com") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        MyAnalytics.screenView(screenName: "MyGoodToGo.com")
        MyAnalytics.event(category: "Tolling", action: "open_link", label: "tolling_good_to_go")

        }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "TollRates")
        refresh(true)
    }

    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        refresh(true)
    }

    func refresh(_ force: Bool){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            TollRateTableStore.updateTollRateTables(force, completion: { error in
                if (error == nil) {
                
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self {
                            
                            if (self?.tollRoute == 509) {
                                
                                if let northboundTollRates = TollRateTableStore.getTollRateTableByRoute(route: 50978) {
                                    self?.northboundTollRates = northboundTollRates
                                }
                                
                                if let southboundTollRates = TollRateTableStore.getTollRateTableByRoute(route: 50983) {
                                    self?.southboundTollRates = southboundTollRates
                                }
                                
                                if (self?.directionSegmentControl.selectedSegmentIndex == 0){
                                    self?.tollTableItem = self!.northboundTollRates

                                } else {
                                    self?.tollTableItem = self!.southboundTollRates

                                }
                            }
                            
                            if let tolls = TollRateTableStore.getTollRateTableByRoute(route: selfValue.stateRoute) {
                                selfValue.tollTableItem = tolls
                                selfValue.messageLabel.text = tolls.message

                            }
                            
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self {
                           selfValue.refreshControl.endRefreshing()
                           selfValue.hideOverlayView()
                           AlertMessages.getConnectionAlert(backupURL: WsdotURLS.tolling, message: WSDOTErrorStrings.tollRates)
                        }
                    }
                }
                
            })
        }
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex){
        case 0:
            tollTableItem = northboundTollRates
            tableView.reloadData()
            break
        case 1:
            tollTableItem = southboundTollRates
            tableView.reloadData()
            break
        default:
            break
        }
    }

    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tollTableItem.tollTable.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tollTableItem.tollTable[indexPath.row].rows.count == 3 {

            let cell = tableView.dequeueReusableCell(withIdentifier: threeColCellIdentifier) as! ThreeColTableCell

            cell.colOneLabel.text = tollTableItem.tollTable[indexPath.row].rows[0]
            cell.colTwoLabel.text = tollTableItem.tollTable[indexPath.row].rows[1]
            cell.colThreeLabel.text = tollTableItem.tollTable[indexPath.row].rows[2]
            
            if #available(iOS 13, *){
                cell.colOneLabel.textColor = UIColor.label
                cell.colTwoLabel.textColor = UIColor.label
                cell.colThreeLabel.textColor = UIColor.label
            } else {
                cell.colOneLabel.textColor = UIColor.black
                cell.colTwoLabel.textColor = UIColor.black
                cell.colThreeLabel.textColor = UIColor.black
            }
            
            
            if (tollTableItem.tollTable[indexPath.row].header) {
                cell.backgroundColor = UIColor.groupTableViewBackground
            } else {
            
                if #available(iOS 13, *){
                    cell.backgroundColor = UIColor.secondarySystemGroupedBackground
                } else {
                    cell.backgroundColor = UIColor.lightText
                }
            
                // highlight current toll
                if TollRateTableStore.isTollActive(
                        startHour: tollTableItem.tollTable[indexPath.row].startHourString,
                        endHour: tollTableItem.tollTable[indexPath.row].endHourString) {
            
                    let now = Date()

                    if ((now.isWeekend || now.is_WAC_468_270_071_Holiday) != tollTableItem.tollTable[indexPath.row].weekday ) {
                        
                        if #available(iOS 13, *){
                            cell.backgroundColor = ThemeManager.currentTheme().darkColor
                            cell.colOneLabel.textColor = UIColor.white
                            cell.colTwoLabel.textColor = UIColor.white
                            cell.colThreeLabel.textColor = UIColor.white
                        } else {
                            cell.backgroundColor = Colors.lightGreen
                        }
                        
                    }
            
                }
            }
        
            return cell
            
        } else if tollTableItem.tollTable[indexPath.row].rows.count == 4 {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: fourColCellIdentifier) as! FourColTableCell

            cell.colOneLabel.text = tollTableItem.tollTable[indexPath.row].rows[0]
            cell.colTwoLabel.text = tollTableItem.tollTable[indexPath.row].rows[1]
            cell.colThreeLabel.text = tollTableItem.tollTable[indexPath.row].rows[2]
            cell.colFourLabel.text = tollTableItem.tollTable[indexPath.row].rows[3]
        
            if #available(iOS 13, *){
                cell.colOneLabel.textColor = UIColor.label
                cell.colTwoLabel.textColor = UIColor.label
                cell.colThreeLabel.textColor = UIColor.label
                cell.colFourLabel.textColor = UIColor.label
            } else {
                cell.colOneLabel.textColor = UIColor.black
                cell.colTwoLabel.textColor = UIColor.black
                cell.colThreeLabel.textColor = UIColor.black
                cell.colFourLabel.textColor = UIColor.black
            }
        
        
            if (tollTableItem.tollTable[indexPath.row].header) {
                cell.backgroundColor = UIColor.groupTableViewBackground
            } else {
                
                if #available(iOS 13, *){
                    cell.backgroundColor = UIColor.secondarySystemGroupedBackground
                } else {
                    cell.backgroundColor = UIColor.lightText
                }
            
                // highlight current toll
                if TollRateTableStore.isTollActive(
                        startHour: tollTableItem.tollTable[indexPath.row].startHourString,
                        endHour: tollTableItem.tollTable[indexPath.row].endHourString) {
            
                    let now = Date()

                    if ((now.isWeekend || now.is_WAC_468_270_071_Holiday) != tollTableItem.tollTable[indexPath.row].weekday ) {
                        if #available(iOS 13, *){
                            cell.backgroundColor = ThemeManager.currentTheme().darkColor
                            cell.colOneLabel.textColor = UIColor.white
                            cell.colTwoLabel.textColor = UIColor.white
                            cell.colThreeLabel.textColor = UIColor.white
                        } else {
                            cell.backgroundColor = Colors.lightGreen
                        }
                    }
                }
            }
        
            return cell
            
        }
        
        return UITableViewCell()
    }
}
