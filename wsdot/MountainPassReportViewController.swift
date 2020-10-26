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
    
    @IBOutlet weak var bannerView: DFPBannerView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mountainPassTabBarContoller = self.tabBarController as! MountainPassTabBarViewController
        
        passItem = mountainPassTabBarContoller.passItem
        
        updatePassReportView(withPassItem: passItem)
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        self.tableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl.frame.size.height)
        refresh(false)
        
        // Ad Banner
        bannerView.adUnitID = ApiKeys.getAdId()
        bannerView.rootViewController = self
        let request = DFPRequest()
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
        
        passReportView.timestampLabel.text = "Updated " + TimeUtils.formatTime(passItem.dateUpdated, format: "MMMM dd, YYYY h:mm a")
 
        if (passItem.weatherCondition != ""){
            passReportView.weatherDetailsLabel.text = passItem.weatherCondition
        } else if (passItem.forecast.count > 0){
            passReportView.weatherDetailsLabel.text = passItem.forecast[0].forecastText
        } else {
            passReportView.weatherDetailsLabel.text = "N/A"
        }
    
        if let temp = passItem.temperatureInFahrenheit.value{
            passReportView.temperatureLabel.text = String(temp) + "°F"
        } else {
            passReportView.temperatureLabel.text = "N/A"
        }

        passReportView.elevationLabel.text = String(passItem.elevationInFeet) + " ft"

        passReportView.conditionsLabel.text = passItem.roadCondition
 
        passReportView.restrictionOneTitleLabel.text = "Restrictions " + passItem.restrictionOneTravelDirection + ":"

        
        passReportView.restrictionOneLabel.text = passItem.restrictionOneText
      
        passReportView.restrictionTwoTitleLabel.text = "Restrictions " + passItem.restrictionTwoTravelDirection + ":"

        
        passReportView.restrictionTwoLabel.text = passItem.restrictionTwoText
        
    }
    
    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        refresh(true)
    }
    
    func refresh(_ force: Bool) {
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
                            selfValue.refreshControl.endRefreshing()
                       
                                                        
                        }
                    }
                }else{
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            AlertMessages.getConnectionAlert(backupURL: WsdotURLS.passes, message: WSDOTErrorStrings.passCameras)
                            
                        }
                    }
                }
            })
        }
    }
    

    
    // MARK: -
    // MARK: Table View Data source methods
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return passReportView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
    
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
