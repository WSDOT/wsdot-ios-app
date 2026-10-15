//
//  RefreshViewController.swift
//  WSDOT
//
//  Copyright (c) 2026 Washington State Department of Transportation
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

class RefreshViewController: UIViewController {

    var activityIndicator = UIActivityIndicatorView()

    func showOverlay(_ view: UIView) {
    
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.color = UIColor.gray
    
        if let splitView = self.splitViewController {
           
            if splitView .isCollapsed {
            
                activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
            
            } else {
            
                activityIndicator.center = CGPoint(x: view.center.x - splitView.viewControllers[0].view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
                
            }
        } else {
            if let nav = self.navigationController  {
                activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - nav.navigationBar.frame.size.height)
            }
        }
    
        view.addSubview(activityIndicator)
    
        activityIndicator.startAnimating()
    }

    func hideOverlayView(){
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}

