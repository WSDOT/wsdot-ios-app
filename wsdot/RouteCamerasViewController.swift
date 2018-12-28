//
//  RouteCameras.swift
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
import SDWebImage

class RouteCamerasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    let camerasCellIdentifier = "TerminalCameras"
    let SegueCamerasViewController = "CamerasViewController"

    let refreshControl = UIRefreshControl()

    var departingTerminalId = -1

    var cameras : [CameraItem] = []

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension

        // refresh controller
        refreshControl.addTarget(self, action: #selector(RouteCamerasViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)

        self.tableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl.frame.size.height)
        
        self.refresh(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "FerryCameras")
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
                            selfValue.cameras = selfValue.filterCameras(CamerasStore.getCamerasByRoadName("Ferries"))
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                        }
                    }
                }else{
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    // MARK: Table View Data source methods
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
        cell.CameraImage.sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: "imagePlaceholder"), options: .refreshCached)
        
        return cell
    }
    
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
                destinationViewController.adTarget = "ferries"
            }
        }
    }
    
    // MARK: -
    // MARK: Helper functions
    func filterCameras(_ cameras: [CameraItem]) -> [CameraItem] {
    
        var filteredCameras = [CameraItem]()
        
        if departingTerminalId != -1 {
        
            for camera in cameras {
            
                let distance = LatLonUtils.haversine(
                    (FerriesConsts().terminalMap[departingTerminalId]?.latitude)!,
                    lonA: (FerriesConsts().terminalMap[departingTerminalId]?.longitude)!,
                    latB: camera.latitude,
                    lonB: camera.longitude)
            
                if (distance < 5280){
                    filteredCameras.append(camera)
                }
            }
        
        }
        
        return filteredCameras
    }
}
