//
//  TollRatesViewController.swift
//  WSDOT
//
//  Copyright (c) 2025 Washington State Department of Transportation
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

class TollRatesTableViewController: RefreshViewController, UITableViewDataSource, UITableViewDelegate {


    @IBOutlet weak var tableView: UITableView!
    
    let cellIdentifier = "TollCell"

    var menu_options: [String] = []
    var menu_icon_names: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Toll Rates"
        
        menu_options = ["SR 16","SR 99","SR 167","SR 509", "SR 520","I-405"]
        menu_icon_names = ["icTabSR16","icTabSR99","icTabSR167","icTabSR509","icTabSR520","icTabI405"]

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! IconCell
        
        cell.label?.text = menu_options[indexPath.row]
        
        if menu_icon_names.indices.contains(indexPath.row) {
            cell.iconView.image = UIImage(named: menu_icon_names[indexPath.row])
        }
        
        return cell
    }
    

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedToll = menu_options[indexPath.row]

        switch selectedToll {
        case "SR 509":
            tollRateView(route: 509)
        case "SR 16":
            tollRateView(route: 16)
        case "SR 520":
            tollRateView(route: 520)
        case "SR 99":
            tollRateView(route: 99)
        case "SR 167":
            tollRateView(route: 167)
        case "I-405":
            tollRateView(route: 405)
        default:
            break
        }
    }
    
    func tollRateView(route: Int){

        let tollViewStoryboard: UIStoryboard = UIStoryboard(name: "TollRates", bundle: nil)
        let tollsNav = tollViewStoryboard.instantiateViewController(withIdentifier: "TollsNav") as! UINavigationController
    
        if (route == 509) {
            let tollRatesTableView = tollViewStoryboard.instantiateViewController(withIdentifier: "TollRatesTableViewController") as! TollRatesTableViewController
            let tollViewTableView = tollViewStoryboard.instantiateViewController(withIdentifier: "SR509") as! TollTableViewController
            tollViewTableView.tollRoute = 509
            tollViewTableView.title = "SR 509"
            if UIDevice.current.userInterfaceIdiom == .pad {
                tollsNav.setViewControllers([tollRatesTableView, tollViewTableView], animated: false)

            } else {
                tollsNav.setViewControllers([tollViewTableView], animated: false)

            }
        }
        
        else if (route == 16) {
            let tollRatesTableView = tollViewStoryboard.instantiateViewController(withIdentifier: "TollRatesTableViewController") as! TollRatesTableViewController
            let tollViewTableView = tollViewStoryboard.instantiateViewController(withIdentifier: "SR16") as! TollTableViewController
            tollViewTableView.tollRoute = 16
            tollViewTableView.title = "SR 16"
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                tollsNav.setViewControllers([tollRatesTableView, tollViewTableView], animated: false)

            } else {
                tollsNav.setViewControllers([tollViewTableView], animated: false)

            }
        }
        else if (route == 520) {
            let tollRatesTableView = tollViewStoryboard.instantiateViewController(withIdentifier: "TollRatesTableViewController") as! TollRatesTableViewController
            let tollViewTableView = tollViewStoryboard.instantiateViewController(withIdentifier: "SR520") as! TollTableViewController
            tollViewTableView.tollRoute = 520
            tollViewTableView.title = "SR 520"
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                tollsNav.setViewControllers([tollRatesTableView, tollViewTableView], animated: false)

            } else {
                tollsNav.setViewControllers([tollViewTableView], animated: false)

            }
        }
        else if (route == 99) {
            let tollRatesTableView = tollViewStoryboard.instantiateViewController(withIdentifier: "TollRatesTableViewController") as! TollRatesTableViewController
            let tollViewTableView = tollViewStoryboard.instantiateViewController(withIdentifier: "SR99") as! TollTableViewController
            tollViewTableView.tollRoute = 99
            tollViewTableView.title = "SR 99"
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                tollsNav.setViewControllers([tollRatesTableView, tollViewTableView], animated: false)
            } else {
                tollsNav.setViewControllers([tollViewTableView], animated: false)

            }
        }
        else if (route == 167) {
            let tollRatesTableView = tollViewStoryboard.instantiateViewController(withIdentifier: "TollRatesTableViewController") as! TollRatesTableViewController
            let dynamicTollRatesViewController = tollViewStoryboard.instantiateViewController(withIdentifier: "SR167") as! DynamicTollRatesViewController
            dynamicTollRatesViewController.stateRoute = "167"
            dynamicTollRatesViewController.title = "SR 167"
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                tollsNav.setViewControllers([tollRatesTableView, dynamicTollRatesViewController], animated: false)

            } else {
                tollsNav.setViewControllers([dynamicTollRatesViewController], animated: false)

            }
        }
        else if (route == 405) {
            let tollRatesTableView = tollViewStoryboard.instantiateViewController(withIdentifier: "TollRatesTableViewController") as! TollRatesTableViewController
            let dynamicTollRatesViewController = tollViewStoryboard.instantiateViewController(withIdentifier: "I405") as! DynamicTollRatesViewController
            dynamicTollRatesViewController.stateRoute = "405"
            dynamicTollRatesViewController.title = "I-405"
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                tollsNav.setViewControllers([tollRatesTableView, dynamicTollRatesViewController], animated: false)
                
            } else {
                tollsNav.setViewControllers([dynamicTollRatesViewController], animated: false)
            }
        }

        setNavController(newNavigationController: tollsNav)

    }

    func setNavController(newNavigationController: UINavigationController){

        let rootViewController = UIApplication.shared.windows.first!.rootViewController as! UISplitViewController
        if (rootViewController.isCollapsed) {
            let nav = rootViewController.viewControllers[0] as! UINavigationController
            nav.pushViewController(newNavigationController, animated: true)
        } else {
            newNavigationController.viewControllers[0].navigationItem.leftBarButtonItem = rootViewController.displayModeButtonItem
            newNavigationController.viewControllers[0].navigationItem.leftItemsSupplementBackButton = true
            rootViewController.showDetailViewController(newNavigationController, sender: self)
        }
    }
}
