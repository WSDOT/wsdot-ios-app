//
//  CameraPagerViewController.swift
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

class CameraPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var pages = [CameraViewController]()
    var selectedCameraIndex = 0
    var cameras: [CameraItem] = []
    
    var containingVC: CameraPageContainerViewController!
    
    var pendingTitle = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.dataSource = self
        self.view.backgroundColor = UIColor.white
        
        let cameraStoryboard = UIStoryboard(name: "Camera", bundle: nil)
        
        self.containingVC!.title = cameras[selectedCameraIndex].title
    
        for camera in cameras {
            let page: CameraViewController! = cameraStoryboard.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
            page.cameraItem = camera
            page.adsEnabled = false
            pages.append(page)
        }
    
        setViewControllers([pages[selectedCameraIndex]], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
  
    }
    
    // MARK - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let currentIndex = pages.index(of: viewController as! CameraViewController)!
        
        if (pages.count == 1 || currentIndex - 1 < 0) {
            return nil
        }
        
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let currentIndex = pages.index(of: viewController as! CameraViewController)!
        
        if (pages.count == 1 || currentIndex + 1 >= pages.count) {
            return nil
        }
        
        let nextIndex = currentIndex + 1
        return pages[nextIndex]
    }
   
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]){
        self.pendingTitle = (pendingViewControllers[0] as! CameraViewController).cameraItem.title
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController],
             transitionCompleted completed: Bool) {
        self.containingVC!.title = self.pendingTitle
    }
 
    // MARK - UIPageViewControllerDataSource
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return selectedCameraIndex
    }

}
