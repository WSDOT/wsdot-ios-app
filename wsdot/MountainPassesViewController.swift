//
//  MountainPassesViewController.swift
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

import UIKit
import Foundation

class MountainPassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "PassCell"
    let segueMountainPassDetailsViewController = "MountainPassDetailsViewController"
    
    var passItems = [MountainPassItem]()

    let refreshControl = UIRefreshControl()
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // refresh controller
        refreshControl.addTarget(self, action: #selector(MountainPassesViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        showOverlay(self.view)
        
        self.passItems = MountainPassStore.getPasses()
        self.tableView.reloadData()
        
        refresh(false)
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Mountain Passes")
    }
    
    func refresh(_ force: Bool){
      DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            MountainPassStore.updatePasses(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.passItems = MountainPassStore.getPasses()
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, selfValue.tableView)
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    func refreshAction(_ sender: UIRefreshControl) {
        refresh(true)
    }

    func showOverlay(_ view: UIView) {
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = UIColor.gray
        
        if self.splitViewController!.isCollapsed {
            activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        } else {
            activityIndicator.center = CGPoint(x: view.center.x - self.splitViewController!.viewControllers[0].view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        }
        
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    func hideOverlayView(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }

    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! MountainPassCell
        
        let passItem = passItems[indexPath.row]
        
        cell.nameLabel.text = passItem.name
        
        if (passItem.forecast.count > 0){
            cell.forecastLabel.text = WeatherUtils.getForecastBriefDescription(passItem.forecast[0].forecastText)
            cell.weatherImage.image = UIImage(named: WeatherUtils.getIconName(passItem.forecast[0].forecastText, title: passItem.forecast[0].day))
        } else {
            cell.forecastLabel.text = ""
            cell.weatherImage.image = nil
        }
        
        if passItem.dateUpdated as Date == Date.init(timeIntervalSince1970: 0){
            cell.updatedLabel.text = "Not Available"
        }else {
            cell.updatedLabel.text = TimeUtils.timeAgoSinceDate(passItem.dateUpdated, numericDates: true)
        }
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform Segue
        performSegue(withIdentifier: segueMountainPassDetailsViewController, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueMountainPassDetailsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let passItem = self.passItems[indexPath.row] as MountainPassItem
                let destinationViewController = segue.destination as! MountainPassTabBarViewController
                destinationViewController.passItem = passItem
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
}
