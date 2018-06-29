//
//  TollRatesViewController.swift
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

class TollRatesViewController: UIViewController{

    let dynamicTollRatesSegue = "dynamicTollRatesSegue"

    var dynamicTollRatesVC: DynamicTollRatesViewController?

    @IBOutlet weak var SR520ContainerView: UIView!
    @IBOutlet weak var SR16ContainerView: UIView!
    @IBOutlet weak var I405ContainerView: UIView!

    let goodToGoUrlString = "https://mygoodtogo.com/olcsc/"

    // Remove and add hairline for nav bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Toll Rates/SR520")
    
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, for: .default)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
    
    // Get a reference to the dynamic toll rates controller for switching data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == dynamicTollRatesSegue {
            dynamicTollRatesVC = segue.destination as? DynamicTollRatesViewController
        }
    }
    
    @IBAction func MyGoodToGoLinkTap(_ sender: UIBarButtonItem) {
        GoogleAnalytics.screenView(screenName: "/Toll Rates/MyGoodToGo.com")
        let svc = SFSafariViewController(url: URL(string: self.goodToGoUrlString)!, entersReaderIfAvailable: true)
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = ThemeManager.currentTheme().mainColor
        }
        self.present(svc, animated: true, completion: nil)
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        
        switch (sender.selectedSegmentIndex){
            
        case 0:
            GoogleAnalytics.screenView(screenName: "/Toll Rates/SR520")
            SR520ContainerView.isHidden = false
            SR16ContainerView.isHidden = true
            I405ContainerView.isHidden = true
            break
        case 1:
            GoogleAnalytics.screenView(screenName: "/Toll Rates/SR16")
            SR520ContainerView.isHidden = true
            SR16ContainerView.isHidden = false
            I405ContainerView.isHidden = true
            break
        case 2:
            GoogleAnalytics.screenView(screenName: "/Toll Rates/SR167")
            SR520ContainerView.isHidden = true
            SR16ContainerView.isHidden = true
            if let tollVC = dynamicTollRatesVC {
                tollVC.stateRoute = "167"
                tollVC.refreshControl.beginRefreshing()
                tollVC.tollRates.removeAll()
                tollVC.tableView.reloadData()
                tollVC.refresh(true)
            }
            I405ContainerView.isHidden = false
            break
        case 3:
            GoogleAnalytics.screenView(screenName: "/Toll Rates/I405")
            SR520ContainerView.isHidden = true
            SR16ContainerView.isHidden = true
            if let tollVC = dynamicTollRatesVC {
                tollVC.stateRoute = "405"
                tollVC.refreshControl.beginRefreshing()
                tollVC.tollRates.removeAll()
                tollVC.tableView.reloadData()
                tollVC.refresh(true)
            }
            I405ContainerView.isHidden = false
            break
        default:
            break
        }
    }
}
