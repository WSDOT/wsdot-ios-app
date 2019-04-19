//
//  TwitterViewController.swift
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

class TwitterViewController: RefreshViewController, UITableViewDelegate, UITableViewDataSource, INDLinkLabelDelegate {
    
    let cellIdentifier = "TwitterCell"
    
    let segueTwitterAccountSelectionViewController = "TwitterAccountSelectionViewController"
    
    var tweets = [TwitterItem]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var accountButton: UIButton!
    
    let refreshControl = UIRefreshControl()

    let accountData: [(name:String, screenName:String?)] =
        [("All Accounts", nil),
         ("Ferries", "wsferries"),
         ("Snoqualmie Pass", "SnoqualmiePass"),
         ("WSDOT", "wsdot"),
         ("WSDOT East","WSDOT_East"),
         ("WSDOT North Traffic", "wsdot_north"),
         ("WSDOT Southwest", "wsdot_sw"),
         ("WSDOT Tacoma","wsdot_tacoma"),
         ("WSDOT Traffic","wsdot_traffic")]
    
    let accountIconNames: Dictionary<String, String> = [
        "wsferries":"icTwitterFerries",
        "SnoqualmiePass":"icTwitterSnoqualmie",
        "wsdot":"icTwitterWsdot",
        "WSDOT_East":"icTwitterWsdotEast",
        "wsdot_north":"icTwitterWsdotNorth",
        "wsdot_sw":"icTwitterWsdotSW",
        "wsdot_tacoma":"icTwitterTacoma",
        "wsdot_traffic":"icTwitterTraffic"
    ]
    
    var currentAccountIndex = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        accountButton.layer.cornerRadius = 8.0
        accountButton.setTitle(accountData[currentAccountIndex].name, for: UIControl.State())
        accountButton.accessibilityHint = "double tap to change account"
        
        tableView.rowHeight = UITableView.automaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(TwitterViewController.refreshAction(_:)), for: .valueChanged)
        
        tableView.addSubview(refreshControl)
        
        showOverlay(self.view)
        tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y - self.refreshControl.frame.size.height)
        refresh(accountData[self.currentAccountIndex].screenName)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "Twitter")
    }
    
    @objc func refreshAction(_ sender: UIRefreshControl){
        refresh(accountData[self.currentAccountIndex].screenName)
    }
    
    func refresh(_ account: String?) {
        
        tweets.removeAll()
        tableView.reloadData()
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { [weak self] in
            TwitterStore.getTweets(account, completion: { data, error in
                if let validData = data {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.tweets = validData
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
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }

    
    @IBAction func selectAccountAction(_ sender: UIButton) {
        performSegue(withIdentifier: segueTwitterAccountSelectionViewController, sender: self)
    }
    
    func accountSelected(_ index: Int){
        currentAccountIndex = index
        accountButton.setTitle(accountData[currentAccountIndex].name, for: UIControl.State())
        showOverlay(self.view)
        refresh(accountData[self.currentAccountIndex].screenName)
    }
    
    
    // MARK: Table View Data Source Methods
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! TwitterCell
        
        let tweet = tweets[indexPath.row]
        
        let htmlStyleString = "<style>body{font-family: '.SFUIText'; font-size: 17.0px;}</style> "
        
        let htmlString = htmlStyleString + tweet.text
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        cell.contentLabel.attributedText = attrStr
        cell.contentLabel.delegate = self
        
        cell.publishedLabel.text = TimeUtils.formatTime(tweet.published, format: "MMMM dd, YYYY h:mm a")
        
        if let iconName = accountIconNames[tweet.screenName] {
            cell.iconView.image = UIImage(named: iconName)
        } else {
            cell.iconView.image = UIImage(named: accountIconNames["wsdot"]!)
        }
        
        if let mediaUrl = tweet.mediaUrl {
            cell.mediaImageView.sd_setImage(with: URL(string: mediaUrl), placeholderImage: UIImage(named: "imagePlaceholder"), options: .refreshCached)
            cell.mediaImageView.layer.cornerRadius = 8.0
        }else{
            cell.mediaImageView.sd_setImage(with: nil)
        }
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let svc = SFSafariViewController(url: URL(string: tweets[indexPath.row].link)!, entersReaderIfAvailable: true)
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = UIColor.white
            svc.preferredBarTintColor = Colors.wsdotPrimary
        } else {
            svc.view.tintColor = Colors.tintColor
        }
        self.present(svc, animated: true, completion: nil)
    }
    
    // MARK: Naviagtion
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueTwitterAccountSelectionViewController {
            let destinationViewController = segue.destination as! TwitterAccountSelectionViewController
            destinationViewController.my_parent = self
            destinationViewController.selectedIndex = currentAccountIndex
        }
    }
    
    // MARK: INDLinkLabelDelegate
    func linkLabel(_ label: INDLinkLabel, didLongPressLinkWithURL URL: Foundation.URL) {
        DispatchQueue.main.async { [weak self] in
            let activityController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
            if let selfValue = self{
                selfValue.present(activityController, animated: true, completion: nil)
            }
        }
    }
    
    func linkLabel(_ label: INDLinkLabel, didTapLinkWithURL URL: Foundation.URL) {
        DispatchQueue.main.async {
            let svc = SFSafariViewController(url: URL, entersReaderIfAvailable: true)
            if #available(iOS 10.0, *) {
                svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
                svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
            } else {
                svc.view.tintColor = ThemeManager.currentTheme().mainColor
            }
            self.present(svc, animated: true, completion: nil)
        }
    }
}
