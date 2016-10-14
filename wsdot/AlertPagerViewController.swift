//
//  AlertPagerViewController.swift
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

class AlertPagerViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

        private var pages = [AlertContentViewController]()
        private var alertItems = [HighwayAlertItem]()
        private var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        let page: AlertContentViewController! = storyboard?.instantiateViewControllerWithIdentifier("AlertContentViewController") as! AlertContentViewController
        page.loadingPage = true
        pages.append(page)
        setViewControllers([pages[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        view.backgroundColor = Colors.lightGrey
        
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.whiteColor()
        UIPageControl.appearance().currentPageIndicatorTintColor = Colors.tintColor
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        pages.removeAll()
        let page: AlertContentViewController! = storyboard?.instantiateViewControllerWithIdentifier("AlertContentViewController") as! AlertContentViewController
        page.loadingPage = true
        pages.append(page)
        setViewControllers([pages[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        fetchAlerts(false)
        timer = NSTimer.scheduledTimerWithTimeInterval(TimeUtils.alertsUpdateTime, target: self, selector: #selector(AlertPagerViewController.updateAlerts(_:)), userInfo: nil, repeats: true)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    func updateAlerts(sender: NSTimer){
        fetchAlerts(false)
    }
    
    private func fetchAlerts(force: Bool) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {[weak self] in
            HighwayAlertsStore.updateAlerts(force, completion: { error in
                if (error == nil){
                    dispatch_async(dispatch_get_main_queue()) {[weak self] in
                        if let selfValue = self{
                            selfValue.pages.removeAll()
                            selfValue.alertItems = HighwayAlertsStore.getHighestPriorityAlerts()
                            selfValue.setUpContent(false)
                        }
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.pages.removeAll()
                            selfValue.setUpContent(true)
                        }
                    }
                }
            })
        }
    }
    
    func setUpContent(failed: Bool){
        
        if (failed){
            let page: AlertContentViewController! = storyboard?.instantiateViewControllerWithIdentifier("AlertContentViewController") as! AlertContentViewController
            page.alertText = "Failed to load alerts"
            pages.append(page)
        }else {
            var alertNumber = 1
            for alert in alertItems {
                let page: AlertContentViewController! = storyboard?.instantiateViewControllerWithIdentifier("AlertContentViewController") as! AlertContentViewController
                page.alert = alert
                page.alertText = alert.headlineDesc
                page.alertCount = alertItems.count
                page.alertNumber = alertNumber
                alertNumber = alertNumber + 1
                pages.append(page)
            }
            if (pages.count == 0){
                let page: AlertContentViewController! = storyboard?.instantiateViewControllerWithIdentifier("AlertContentViewController") as! AlertContentViewController
                page.alertText = "No highest impact alerts"
                pages.append(page)
            }
        }
        setViewControllers([pages[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        if (pages.count == 1){
            return nil
        }
        
        let currentIndex = pages.indexOf(viewController as! AlertContentViewController)!
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if (pages.count == 1){
            return nil
        }
        
        let currentIndex = pages.indexOf(viewController as! AlertContentViewController)!
        let nextIndex = abs((currentIndex + 1) % pages.count)
        return pages[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}
