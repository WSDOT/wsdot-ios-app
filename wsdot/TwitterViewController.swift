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

class TwitterViewController: UIViewController, UITabBarDelegate, UITableViewDataSource, INDLinkLabelDelegate {
    
    let cellIdentifier = "TwitterCell"
    
    let segueTwitterAccountSelectionViewController = "TwitterAccountSelectionViewController"
    
    var tweets = [TwitterItem]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var accountButton: UIButton!
    
    let refreshControl = UIRefreshControl()
    var activityIndicator = UIActivityIndicatorView()

    let accountData: [(name:String, screenName:String?)] =
        [("All Accounts", nil), ("Ferries", "wsferries"), ("Good To Go!", "GoodToGoWSDOT"),
        ("Snoqualmie Pass", "SnoqualmiePass"), ("WSDOT", "wsdot"), ("WSDOT Jobs", "WSDOTjobs"), ("WSDOT North Traffic", "wsdot_north"), ("WSDOT Southwest", "wsdot_sw"),
        ("WSDOT Tacoma","wsdot_tacoma"), ("WSDOT Traffic","wsdot_traffic")]
    
    let accountIconNames: Dictionary<String, String> = [
        "wsferries":"icTwitterFerries",
        "GoodToGoWSDOT":"icTwitterGoodToGo",
        "SnoqualmiePass":"icTwitterSnoqualmie",
        "wsdot":"icTwitterWsdot",
        "WSDOTjobs":"icTwitterJobs",
        "wsdot_north":"icTwitterWsdotNorth",
        "wsdot_sw":"icTwitterWsdotSW",
        "wsdot_tacoma":"icTwitterTacoma",
        "wsdot_traffic":"icTwitterTraffic"
    ]
    
    var currentAccountIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "WSDOT on Twitter"
        
        accountButton.layer.cornerRadius = 8.0
        accountButton.setTitle("All Accounts", forState: .Normal)
        accountButton.accessibilityHint = "double tap to change account"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(TwitterViewController.refreshAction(_:)), forControlEvents: .ValueChanged)
        
        tableView.addSubview(refreshControl)
        
        showOverlay(self.view)
        tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y - self.refreshControl.frame.size.height)
        refresh(accountData[self.currentAccountIndex].screenName)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Social Media/Twitter")
    }
    
    func refreshAction(sender: UIRefreshControl){
        refresh(accountData[self.currentAccountIndex].screenName)
    }
    
    func refresh(account: String?) {
        
        tweets.removeAll()
        tableView.reloadData()
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { [weak self] in
            TwitterStore.getTweets(account, completion: { data, error in
                if let validData = data {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.tweets = validData
                            selfValue.tableView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    func showOverlay(view: UIView) {
        activityIndicator.frame = CGRectMake(0, 0, 40, 40)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.color = UIColor.grayColor()
        
        if self.splitViewController!.collapsed {
            activityIndicator.center = CGPointMake(view.center.x, view.center.y - self.navigationController!.navigationBar.frame.size.height)
        } else {
            activityIndicator.center = CGPointMake(view.center.x - self.splitViewController!.viewControllers[0].view.center.x, view.center.y - self.navigationController!.navigationBar.frame.size.height)
        }
        
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    func hideOverlayView(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    @IBAction func selectAccountAction(sender: UIButton) {
        performSegueWithIdentifier(segueTwitterAccountSelectionViewController, sender: self)
    }
    
    func accountSelected(index: Int){
        currentAccountIndex = index
        accountButton.setTitle(accountData[currentAccountIndex].name, forState: .Normal)
        showOverlay(self.view)
        refresh(accountData[self.currentAccountIndex].screenName)
    }
    
    
    // MARK: Table View Data Source Methods
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! TwitterCell
        
        let tweet = tweets[indexPath.row]
        
        let htmlStyleString = "<style>body{font-family: '\(cell.contentLabel.font.fontName)'; font-size:\(cell.contentLabel.font.pointSize)px;}</style>"
        
        let htmlString = htmlStyleString + tweet.text
        
        let attrStr = try! NSMutableAttributedString(
            data: htmlString.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        cell.contentLabel.attributedText = attrStr
        cell.contentLabel.delegate = self
        
        cell.publishedLabel.text = TimeUtils.formatTime(tweet.published, format: "MMMM dd, YYYY h:mm a")
        
        if let iconName = accountIconNames[tweet.screenName] {
            cell.iconView.image = UIImage(named: iconName)
        }
        
        if let mediaUrl = tweet.mediaUrl {
            cell.mediaImageView.sd_setImageWithURL(NSURL(string: mediaUrl), placeholderImage: UIImage(named: "imagePlaceholder"), options: .RefreshCached)
            cell.mediaImageView.layer.cornerRadius = 8.0
        }else{
            cell.mediaImageView.sd_setImageWithURL(nil)
        }
        
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        UIApplication.sharedApplication().openURL(NSURL(string: tweets[indexPath.row].link)!)
    }
    
    // MARK: Naviagtion
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueTwitterAccountSelectionViewController {
            let destinationViewController = segue.destinationViewController as! TwitterAccountSelectionViewController
            destinationViewController.parent = self
            destinationViewController.selectedIndex = currentAccountIndex
        }
    }
    
    // MARK: INDLinkLabelDelegate
    func linkLabel(label: INDLinkLabel, didLongPressLinkWithURL URL: NSURL) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            let activityController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
            if let selfValue = self{
                selfValue.presentViewController(activityController, animated: true, completion: nil)
            }
        }
    }
    
    func linkLabel(label: INDLinkLabel, didTapLinkWithURL URL: NSURL) {
        dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().openURL(URL)
        }
    }
}
