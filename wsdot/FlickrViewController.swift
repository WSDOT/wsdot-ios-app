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
        refreshControl.addTarget(self, action: #selector(FacebookViewController.refreshAction(_:)), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        showOverlay(self.view)
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Social Media/Flickr")
    }
    
    func refreshAction(_ sender: UIRefreshControl){
        refresh()
    }
    
    func refresh() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { [weak self] in
            FlickrStore.getPosts({ data, error in
                if let validData = data {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.photos = validData
                            selfValue.collectionView.reloadData()
                            selfValue.refreshControl.endRefreshing()
                            selfValue.hideOverlayView()
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.hideOverlayView()
                            selfValue.refreshControl.endRefreshing()
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
    
    // MARK: - UICollectionViewDataSource protocol
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow))
        return CGSize(width: size, height: size)
    }
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlickrCollectionCell
        let post = photos[indexPath.row]
        
        cell.postImage.sd_setImage(with: URL(string: post.mediaLink), placeholderImage: UIImage(named: "imagePlaceholder"), options: .refreshCached)
        
        cell.imageTitle.text = post.title

        return cell
    }

    // MARK: - UICollectionViewDelegate protocol

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        UIApplication.shared.openURL(URL(string: photos[indexPath.row].link)!)

    }
}
