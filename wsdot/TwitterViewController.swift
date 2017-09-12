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

class TwitterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, INDLinkLabelDelegate {
    
    let cellIdentifier = "TwitterCell"
    
    let segueTwitterAccountSelectionViewController = "TwitterAccountSelectionViewController"
    
    var tweets = [TwitterItem]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var accountButton: UIButton!
    
    let refreshControl = UIRefreshControl()
    var activityIndicator = UIActivityIndicatorView()

    let accountData: [(name:String, screenName:String?)] =
        [("All Accounts", nil),
         ("Ferries", "wsferries"),
         ("Good To Go!", "GoodToGoWSDOT"),
         ("Snoqualmie Pass", "SnoqualmiePass"),
         ("WSDOT", "wsdot"),
         ("WSDOT East","WSDOT_East"),
         ("WSDOT North Traffic", "wsdot_north"),
         ("WSDOT Southwest", "wsdot_sw"),
         ("WSDOT Tacoma","wsdot_tacoma"),
         ("WSDOT Traffic","wsdot_traffic")]
    
    let accountIconNames: Dictionary<String, String> = [
        "wsferries":"icTwitterFerries",
        "GoodToGoWSDOT":"icTwitterGoodToGo",
        "SnoqualmiePass":"icTwitterSnoqualmie",
        "wsdot":"icTwitterWsdot",
        "WSDOT_East":"icTwitterWsdotEast",
        "wsdot_north":"icTwitterWsdotNorth",
        "wsdot_sw":"icTwitterWsdotSW",
        "wsdot_tacoma":"icTwitterTacoma",
        "wsdot_traffic":"icTwitterTraffic"
    ]
    
    var currentAccountIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        accountButton.layer.cornerRadius = 8.0
        accountButton.setTitle("All Accounts", for: UIControlState())
        accountButton.accessibilityHint = "double tap to change account"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(TwitterViewController.refreshAction(_:)), for: .valueChanged)
        
        tableView.addSubview(refreshControl)
        
        showOverlay(self.view)
        tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y - self.refreshControl.frame.size.height)
        refresh(accountData[self.currentAccountIndex].screenName)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Traffic Map/Traveler Information/Twitter")
    }
    
    func refreshAction(_ sender: UIRefreshControl){
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
    
    @IBAction func selectAccountAction(_ sender: UIButton) {
        performSegue(withIdentifier: segueTwitterAccountSelectionViewController, sender: self)
    }
    
    func accountSelected(_ index: Int){
        currentAccountIndex = index
        accountButton.setTitle(accountData[currentAccountIndex].name, for: UIControlState())
        showOverlay(self.view)
        refresh(accountData[self.currentAccountIndex].screenName)
    }
    
    
    // MARK: Table View Data Source Methods
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
        
        let htmlStyleString = "<style>body{font-family: '\(cell.contentLabel.font.fontName)'; font-size:\(cell.contentLabel.font.pointSize)px;}</style>"
        
        let htmlString = htmlStyleString + tweet.text
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.data(using: String.Encoding.unicode, allowLossyConversion: false)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        cell.contentLabel.attributedText = attrStr
        cell.contentLabel.delegate = self
        
        cell.publishedLabel.text = TimeUtils.formatTime(tweet.published, format: "MMMM dd, YYYY h:mm a")
        
        if let iconName = accountIconNames[tweet.screenName] {
            cell.iconView.image = UIImage(named: iconName)
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
        UIApplication.shared.openURL(URL(string: tweets[indexPath.row].link)!)
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
                UIApplication.shared.openURL(URL)
        }
    }
}
