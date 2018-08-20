//
//  TollRatesViewController.swift
//  WSDOT
//
//  Copyright (c) 2018 Washington State Department of Transportation
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

    @IBOutlet weak var TollTabBarContainerView: UIView!

    let goodToGoUrlString = "https://mygoodtogo.com/olcsc/"

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Toll Rates/SR 520")
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
    
}
