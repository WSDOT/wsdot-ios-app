//
//  YouTubeViewController.swift
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
import Foundation
import SafariServices

class YouTubeViewController: RefreshViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier = "YouTubeCell"
    
    var videoItems = [YouTubeItem]()
    let refreshControl = UIRefreshControl()
    var overlayView = UIView()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(YouTubeViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        showOverlay(self.view)
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "YouTube")
    }
    
    @objc func refreshAction(_ sender: UIRefreshControl){
        refresh()
    }
    
    func refresh() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { [weak self] in
            YouTubeStore.getVideos({ data, error in
                if let validData = data {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.videoItems = validData
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                            AlertMessages.getConnectionAlert(backupURL: nil)
                        }
                    }
                }
            })
        }
    }
    
    // MARK: Table View Data Source Methods
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! YouTubeCell
        
        let video = videoItems[indexPath.row]
        
        cell.titleLabel.text = video.title
        cell.publishedLabel.text = TimeUtils.formatTime(video.published, format: "MMMM dd, YYYY h:mm a")
        cell.videoThumbnailView.sd_setImage(with: URL(string: video.thumbnailLink), placeholderImage: UIImage(named: "imagePlaceholderSmall"), options: .refreshCached)
        cell.videoThumbnailView.layer.cornerRadius = 8.0
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let svc = SFSafariViewController(url: URL(string: videoItems[indexPath.row].link)!, entersReaderIfAvailable: true)
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = ThemeManager.currentTheme().mainColor
        }
        self.present(svc, animated: true, completion: nil)
    }
}
