//
//  MountainPassReport.swift
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
import GoogleMobileAds

class MountainPassReportViewController: RefreshViewController, UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate {

    let camerasCellIdentifier = "PassCamerasCell"
    let SegueCamerasViewController = "CamerasViewController"
    
    let refreshControl = UIRefreshControl()
    
    var passItem : MountainPassItem = MountainPassItem()
    
    var cameras : [CameraItem] = []
    
    let passReportView = PassReportView()
    
    @IBOutlet weak var bannerView: GAMBannerView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        passReportView.mountainPassIconLabel.text = "Mountain Pass Report"
        passReportView.mountainPassIconImage.image = UIImage(named: "mountainpass_icon")
        
        passReportView.mountainPassIconStack.backgroundColor = UIColor(red: 28/255, green: 120/255, blue: 205/255, alpha: 0.2)
        passReportView.mountainPassIconStack.layer.borderColor = UIColor(red: 28/255, green: 120/255, blue: 205/255, alpha: 1.0).cgColor
        passReportView.mountainPassIconStack.layer.borderWidth = 1
        passReportView.mountainPassIconStack.layer.cornerRadius = 4.0
        
        let mountainPassTabBarContoller = self.tabBarController as! MountainPassTabBarViewController
        
        passItem = mountainPassTabBarContoller.passItem
        
        updatePassReportView(withPassItem: passItem)
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        self.tableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl.frame.size.height)
        refresh(false)
        
        showOverlay(self.view)
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.getAdId()
        bannerView.adSize = getFullWidthAdaptiveAdSize()
        bannerView.rootViewController = self
        let request = GAMRequest()
        request.customTargeting = ["wsdotapp":"passes"]
        
        bannerView.load(request)
        bannerView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "PassReport")
    }
    
    func updatePassReportView(withPassItem: MountainPassItem) {
        passItem = withPassItem
        
        passReportView.mountainPassTitle.text = passItem.name

        // Elevation
        passReportView.elevationLabel.attributedText = elevationLabel(label: "Elevation: ", passItem: String(passItem.elevationInFeet), elevation: " ft")
 
        // Travel Restrictions
        passReportView.restrictionOneLabel.attributedText = restrictionLabel(label: "Travel ", direction: passItem.restrictionOneTravelDirection, passItem: passItem.restrictionOneText)

        passReportView.restrictionTwoLabel.attributedText = restrictionLabel(label: "Travel ", direction: passItem.restrictionTwoTravelDirection, passItem: passItem.restrictionTwoText)
        
        // Conditions
        if (passItem.roadCondition != ""){
            passReportView.conditionsLabel.attributedText = conditionsLabel(label: "Conditions: ", passItem: passItem.roadCondition)
        }
        else {
            passReportView.conditionsLabel.attributedText = conditionsLabel(label: "Conditions: ", passItem: "N/A")
        }
        
        // Weather
        if (passItem.weatherCondition != ""){
            passReportView.weatherDetailsLabel.attributedText = weatherLabel(label: "Weather: ", passItem: passItem.weatherCondition)
        }
        else if (passItem.forecast.count > 0){
            passReportView.weatherDetailsLabel.attributedText = weatherLabel(label: "Weather: ", passItem: passItem.forecast[0].forecastText)
        } else {
            passReportView.weatherDetailsLabel.attributedText = weatherLabel(label: "Weather: ", passItem: "N/A")
        }
    
        // Temperature
        if let temp = passItem.temperatureInFahrenheit.value{
            passReportView.temperatureLabel.attributedText = temperatureLabel(label: "Temperature: ", passItem: String(temp), fahrenheit: "°F")
        } else {
            passReportView.temperatureLabel.attributedText = temperatureLabel(label: "Temperature: ", passItem: "N/A", fahrenheit: "")
        }
        
        // Time Stamp
        passReportView.timestampLabel.text = "Last updated: " + TimeUtils.formatTime(passItem.dateUpdated, format: "MMMM dd, YYYY h:mm a")
    }
    
    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        refresh(true)
    }
    
    func elevationLabel(label: String, passItem: String, elevation: String) ->  NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)]
        let ContentAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)]
        let label = NSMutableAttributedString(string: label, attributes: titleAttributes)
        let content = NSMutableAttributedString(string: passItem, attributes: ContentAttributes)
        let elevation = NSMutableAttributedString(string: elevation, attributes: ContentAttributes)
        label.append(content)
        label.append(elevation)
        return label
    }
    
    func conditionsLabel(label: String, passItem: String) ->  NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)]
        let ContentAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)]
        let label = NSMutableAttributedString(string: label, attributes: titleAttributes)
        let content = NSMutableAttributedString(string: passItem, attributes: ContentAttributes)
        label.append(content)
        return label
    }
    
    func restrictionLabel(label: String, direction: String, passItem: String) ->  NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)]
        let ContentAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)]
        let label = NSMutableAttributedString(string: label, attributes: titleAttributes)
        let direction = NSMutableAttributedString(string: direction, attributes: titleAttributes)
        let colon = NSMutableAttributedString(string: ": ", attributes: titleAttributes)
        let content = NSMutableAttributedString(string: passItem, attributes: ContentAttributes)
        label.append(direction)
        label.append(colon)
        label.append(content)
        return label
    }
    
    func weatherLabel(label: String, passItem: String) ->  NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)]
        let ContentAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)]
        let label = NSMutableAttributedString(string: label, attributes: titleAttributes)
        let passItem = NSMutableAttributedString(string: passItem, attributes: ContentAttributes)
        label.append(passItem)
        return label
    }
    
    func temperatureLabel(label: String, passItem: String, fahrenheit: String) ->  NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)]
        let ContentAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)]
        let label = NSMutableAttributedString(string: label, attributes: titleAttributes)
        let content = NSMutableAttributedString(string: passItem, attributes: ContentAttributes)
        let elevation = NSMutableAttributedString(string: fahrenheit, attributes: ContentAttributes)
        label.append(content)
        label.append(elevation)
        return label
    }
    
    

    
    
    func refresh(_ force: Bool) {
        
        // refresh cameras
        DispatchQueue.global().async {[weak self] in
            CamerasStore.updateCameras(force, completion: { error in
                if (error == nil){
                    DispatchQueue.main.async {[weak self] in
                        if let selfValue = self{
                        
                            var ids = [Int]()
                            for camera in selfValue.passItem.cameraIds{
                                ids.append(camera.cameraId)
                            }
                            selfValue.cameras = CamerasStore.getCamerasByID(ids)
                            selfValue.tableView.reloadData()
                            selfValue.hideOverlayView()
                            selfValue.refreshControl.endRefreshing()
                                                        
                        }
                    }
                }else{
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.passes, message: WSDOTErrorStrings.passCameras)
                            selfValue.hideOverlayView()
                            selfValue.refreshControl.endRefreshing()
                        }
                    }
                }
            })
        }
        
        // refresh report
        DispatchQueue.global().async { [weak self] in
            MountainPassStore.updatePasses(true, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            
                            if let passItem = (MountainPassStore.getPasses().filter{ $0.id == selfValue.passItem.id }.first) {
                                    selfValue.passItem = passItem
                                    selfValue.updatePassReportView(withPassItem: selfValue.passItem)
                    
                            }
                         
                        }
                      
                    }
                } else {
                    AlertMessages.getConnectionAlert(backupURL: WsdotURLS.passes, message: WSDOTErrorStrings.passReport)
                    
                }
            })
        }
        
        
    }
    

    
    // MARK: -
    // MARK: Table View Data source methods
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return passReportView
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Live Cameras"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cameras.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: camerasCellIdentifier) as! CameraImageCustomCell
        
        // Add timestamp to help prevent caching
        let urlString = cameras[indexPath.row].url + "?" + String(Int(Date().timeIntervalSince1970 / 60))
        
        cell.CameraImage.sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: "imagePlaceholder"), options: .refreshCached, completed: { image, error, cacheType, imageURL in
            if (error != nil) {
                cell.CameraImage.image = UIImage(named: "cameraOffline")
            }
        })
 
        return cell
    }
    
    // MARK: -
    // MARK: Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Perform Segue
        performSegue(withIdentifier: SegueCamerasViewController, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueCamerasViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let cameraItem = self.cameras[indexPath.row] as CameraItem
                let destinationViewController = segue.destination as! CameraViewController
                destinationViewController.cameraItem = cameraItem
                destinationViewController.adTarget = "passes"
            }
        }
    }
    
    // MARK: -
    // MARK: Ads
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isAccessibilityElement = true
        bannerView.accessibilityLabel = "advertisement banner."
    }
    

}
