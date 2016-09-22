//
//  FlickrViewController.swift
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

class FlickrViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    let reuseIdentifier = "FlickrCell"
    
    let numberOfItemsPerRow = 2
    
    var photos = [FlickrItem]()
    let refreshControl = UIRefreshControl()
    var activityIndicator = UIActivityIndicatorView()

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WSDOT on Flickr"
           
        // refresh controller
        refreshControl.addTarget(self, action: #selector(FacebookViewController.refreshAction(_:)), forControlEvents: .ValueChanged)
        collectionView.addSubview(refreshControl)
        showOverlay(self.view)
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView("/Social Media/Flickr")
    }
    
    func refreshAction(sender: UIRefreshControl){
        refresh()
    }
    
    func refresh() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { [weak self] in
            FlickrStore.getPosts({ data, error in
                if let validData = data {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.photos = validData
                            selfValue.collectionView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.hideOverlayView()
                            selfValue.refreshControl.endRefreshing()
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
    
    // MARK: - UICollectionViewDataSource protocol
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow))
        return CGSize(width: size, height: size)
    }
    
    // tell the collection view how many cells to make
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    // make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlickrCollectionCell
        let post = photos[indexPath.row]
        
        cell.postImage.sd_setImageWithURL(NSURL(string: post.mediaLink), placeholderImage: UIImage(named: "imagePlaceholder"), options: .RefreshCached)
        
        cell.imageTitle.text = post.title

        return cell
    }

    // MARK: - UICollectionViewDelegate protocol

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        UIApplication.sharedApplication().openURL(NSURL(string: photos[indexPath.row].link)!)
        
        print("You selected cell #\(indexPath.item)!")
    }
}
