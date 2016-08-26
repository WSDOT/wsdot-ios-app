//
//  AlertPagerViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 8/26/16.
//  Copyright © 2016 WSDOT. All rights reserved.
//


import UIKit

class AlertPagerViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

        var pages = [AlertContentViewController]()
        var alertItems = [HighwayAlertItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        let page: AlertContentViewController! = storyboard?.instantiateViewControllerWithIdentifier("AlertContentViewController") as! AlertContentViewController
        page.loadingPage = true
        pages.append(page)
        setViewControllers([pages[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        fetchAlerts(false)
        
        view.backgroundColor = Colors.lightGrey
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.whiteColor()
        UIPageControl.appearance().currentPageIndicatorTintColor = Colors.tintColor
        
    }
    
    private func fetchAlerts(force: Bool) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {[weak self] in
            HighwayAlertsStore.updateAlerts(force, completion: { error in
                if (error == nil){
                    dispatch_async(dispatch_get_main_queue()) {[weak self] in
                        if let selfValue = self{
                            selfValue.pages.removeAll()
                            selfValue.alertItems = HighwayAlertsStore.getHighestPriorityAlerts()
                            selfValue.setUpContent()
  
                        }
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
                        if let selfValue = self{
                            selfValue.presentViewController(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }

    func setUpContent(){
    
        for alert in alertItems {
            let page: AlertContentViewController! = storyboard?.instantiateViewControllerWithIdentifier("AlertContentViewController") as! AlertContentViewController
            page.alertText = alert.headlineDesc
            pages.append(page)
        }
        if (pages.count == 0){
            let page: AlertContentViewController! = storyboard?.instantiateViewControllerWithIdentifier("AlertContentViewController") as! AlertContentViewController
            page.alertText = "No highest impact alerts"
            pages.append(page)
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
