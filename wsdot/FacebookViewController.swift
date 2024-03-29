//
//  FacebookViewController.swift
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
import SafariServices

class FacebookViewController: RefreshViewController, UITableViewDataSource, UITableViewDelegate, INDLinkLabelDelegate {
    
    let cellIdentifier = "postCell"
    
    let facebookBaseUrlString = "https://facebook.com/"
    
    var posts = [FacebookItem]()
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(FacebookViewController.refreshAction(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        showOverlay(self.view)
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "Facebook")
    }
    
    @objc func refreshAction(_ sender: UIRefreshControl){
        refresh()
    }
    
    func refresh() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { [weak self] in
            FacebookStore.getPosts({ data, error in
                if let validData = data {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.posts = validData
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
                            AlertMessages.getConnectionAlert(backupURL: nil, message: WSDOTErrorStrings.posts)
                            
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
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! FacebookCell
        
        let post = posts[indexPath.row]
        
        let htmlStyleString = "<style>body{font-family: '-apple-system'; font-size:\(cell.contentLabel.font.pointSize)px;}</style>"
        
        let htmlString = htmlStyleString + post.message
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        cell.contentLabel.delegate = self
        cell.contentLabel.attributedText = attrStr
        cell.updatedLabel.text = TimeUtils.formatTime(post.createdAt, format: "MMMM dd, YYYY h:mm a")
        
        if #available(iOS 13, *) {
            cell.contentLabel.textColor = UIColor.label
        }
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let svc = SFSafariViewController(url: URL(string: self.facebookBaseUrlString + posts[indexPath.row].id)!, configuration: config)
        
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = UIColor.white
            svc.preferredBarTintColor = Colors.wsdotPrimary
        } else {
            svc.view.tintColor = Colors.tintColor
        }
        self.present(svc, animated: true, completion: nil)
    }
    
    // MARK: INDLinkLabelDelegate
    func linkLabel(_ label: INDLinkLabel, didLongPressLinkWithURL URL: Foundation.URL) {
        let activityController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    func linkLabel(_ label: INDLinkLabel, didTapLinkWithURL URL: Foundation.URL) {
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let svc = SFSafariViewController(url: URL, configuration: config)
        
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = ThemeManager.currentTheme().mainColor
        }
        self.present(svc, animated: true, completion: nil)
    }
}
