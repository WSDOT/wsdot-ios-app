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
import SafariServices

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
    @IBOutlet weak var infoLinkButton: UIButton!
    
    var tollId: Int = 0

    @IBOutlet weak var directionSegmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showOverlay(self.view)
        
        directionSegmentControl.isHidden = true
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(TollTableViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        infoLinkButton.tintColor = ThemeManager.currentTheme().darkColor
        
        self.edgesForExtendedLayout = []
        
        let websiteButton = UIBarButtonItem(title: "My Good To Go", style: .plain, target: self, action: #selector(goodToGoWebsite))
           navigationItem.rightBarButtonItem = websiteButton
        
        // SR 509 Expressway
        if (self.tollId == 3) {
            
            directionSegmentControl.isHidden = false
            
            // SR 509 Expressway Northbound
            if let northboundTollRates = TollRateTableStore.getTollRateTableByRoute(id: 3) {
                self.tollTableItem = northboundTollRates
            }
            
            // SR 509 Expressway Southbound
            if let southboundTollRates = TollRateTableStore.getTollRateTableByRoute(id: 4) {
                self.tollTableItem = southboundTollRates
            }
            
            if (directionSegmentControl.selectedSegmentIndex == 0){
                tollTableItem = northboundTollRates
                if (northboundTollRates.message != "") {
                    messageLabel.text = northboundTollRates.message
                    infoLinkButton.isHidden = true
                }

            } else {
                tollTableItem = southboundTollRates
                if (southboundTollRates.message != "") {
                    messageLabel.text = southboundTollRates.message
                    infoLinkButton.isHidden = true
                }
            }
        }
        
        else if let tolls = TollRateTableStore.getTollRateTableByRoute(id: tollId) {
            tollTableItem = tolls

            if (tolls.message != "") {
                messageLabel.text = tolls.message
                infoLinkButton.isHidden = true
            }
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
                            
                            // SR 509 Expressway
                            if (self?.tollId == 3) {
                                
                                // SR 509 Expressway Northbound
                                if let northboundTollRates = TollRateTableStore.getTollRateTableByRoute(id: 3) {
                                    self?.northboundTollRates = northboundTollRates
                                }
                                
                                // SR 509 Expressway Southbound
                                if let southboundTollRates = TollRateTableStore.getTollRateTableByRoute(id: 4) {
                                    self?.southboundTollRates = southboundTollRates
                                }
                                
                                if (self?.directionSegmentControl.selectedSegmentIndex == 0){
                                    self?.tollTableItem = self!.northboundTollRates
                                    if (self?.northboundTollRates.message != "") {
                                        self?.messageLabel.text = self?.northboundTollRates.message
                                        self?.infoLinkButton.isHidden = true
                                    }

                                } else {
                                    self?.tollTableItem = self!.southboundTollRates
                                    if (self?.southboundTollRates.message != "") {
                                        self?.messageLabel.text = self?.northboundTollRates.message
                                        self?.infoLinkButton.isHidden = true
                                    }

                                }
                            }
                            
                            else if let tolls = TollRateTableStore.getTollRateTableByRoute(id: selfValue.tollId) {
                                selfValue.tollTableItem = tolls
                                
                                if (tolls.message != "") {
                                    selfValue.messageLabel.text = tolls.message
                                    selfValue.infoLinkButton.isHidden = true
                                }

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
    
    @IBAction func infoLinkAction(_ sender: UIButton) {
        if tollId == 1 {
            MyAnalytics.event(category: "Tolling", action: "open_link", label: "tolling_16")
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false
            let svc = SFSafariViewController(url: URL(string: "https://wsdot.wa.gov/travel/roads-bridges/toll-roads-bridges-tunnels/tacoma-narrows-bridge-tolling")!, configuration: config)
            
            if #available(iOS 10.0, *) {
                svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
                svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
            } else {
                svc.view.tintColor = ThemeManager.currentTheme().mainColor
            }
            self.present(svc, animated: true, completion: nil)
        } else if tollId == 2 {
            MyAnalytics.event(category: "Tolling", action: "open_link", label: "tolling_99")

            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false
            let svc = SFSafariViewController(url: URL(string: "https://wsdot.wa.gov/travel/roads-bridges/toll-roads-bridges-tunnels/sr-99-tunnel-tolling")!, configuration: config)
            
            if #available(iOS 10.0, *) {
                svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
                svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
            } else {
                svc.view.tintColor = ThemeManager.currentTheme().mainColor
            }
            self.present(svc, animated: true, completion: nil)
        }
     else if tollId == 3 {
        MyAnalytics.event(category: "Tolling", action: "open_link", label: "tolling_509")
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let svc = SFSafariViewController(url: URL(string: "https://wsdot.wa.gov/travel/roads-bridges/toll-roads-bridges-tunnels/sr-509-expressway")!, configuration: config)
        
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = ThemeManager.currentTheme().mainColor
        }
        self.present(svc, animated: true, completion: nil)
    }
        else if tollId == 5 {
           MyAnalytics.event(category: "Tolling", action: "open_link", label: "tolling_520")
           
           let config = SFSafariViewController.Configuration()
           config.entersReaderIfAvailable = false
           let svc = SFSafariViewController(url: URL(string: "https://wsdot.wa.gov/travel/roads-bridges/toll-roads-bridges-tunnels/sr-520-bridge-tolling")!, configuration: config)
           
           if #available(iOS 10.0, *) {
               svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
               svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
           } else {
               svc.view.tintColor = ThemeManager.currentTheme().mainColor
           }
           self.present(svc, animated: true, completion: nil)
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
