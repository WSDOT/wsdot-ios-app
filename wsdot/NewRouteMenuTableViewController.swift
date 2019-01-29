//
//  NewRouteMenuTableViewController.swift
//  WSDOT
//
//  Created by Logan Sims on 1/29/19.
//  Copyright © 2019 WSDOT. All rights reserved.
//

import Foundation

class NewRouteMenuTableViewController: UITableViewController  {

    @IBOutlet weak var originCell: SelectionCell!
    @IBOutlet weak var destinationCell: SelectionCell!
    
    @IBOutlet weak var submitCell: UITableViewCell!
    @IBOutlet weak var submitLabel: UILabel!
    
    var newRouteMenuEventDelegate: NewRouteMenuEventDelegate!
    
    override func viewDidLoad() {
          submitLabel.textColor = Colors.wsdotPrimary
          definesPresentationContext = false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            newRouteMenuEventDelegate.searchRoutes()
            tableView.deselectRow(at: indexPath, animated: true)
            break
        default:
            newRouteMenuEventDelegate.locationSearch(indexPath.row)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
