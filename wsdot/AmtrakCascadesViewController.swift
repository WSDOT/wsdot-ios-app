//
//  AmtrakCascadesViewController.swift
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
import SafariServices

class AmtrakCascadesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    let cellIdentifier = "AmtrakCell"
    let segueAmtrakSchedulesViewController = "AmtrakCascadesScheduleViewController"

    let menu_options = ["Buy Tickets on Amtrak.com", "Check Schedules and Status"]
    let amtrakUrlString = "https://m.amtrak.com"

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MyAnalytics.screenView(screenName: "AmtrakCascades")
    }

    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = menu_options[indexPath.row]
     
        return cell
    }
    
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform Segue
        switch (indexPath.row) {
        case 0:
            MyAnalytics.screenView(screenName: "BuyTickets")
            MyAnalytics.event(category: "Amtrak", action: "open_url", label: "buy_tickets")
            let svc = SFSafariViewController(url: URL(string: self.amtrakUrlString)!, entersReaderIfAvailable: true)
            
            if #available(iOS 10.0, *) {
                svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
                svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
            } else {
                svc.view.tintColor = ThemeManager.currentTheme().mainColor
            }
            
            self.present(svc, animated: true, completion: nil)
            break
        case 1:
            performSegue(withIdentifier: segueAmtrakSchedulesViewController, sender: self)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
