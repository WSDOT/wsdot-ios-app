//
//  NewRouteMenuTableViewController.swift
//  WSDOT
//
//  Copyright (c) 2019 Washington State Department of Transportation
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

class NewRouteMenuTableViewController: UITableViewController  {

    @IBOutlet weak var originCell: SelectionCell!
    @IBOutlet weak var destinationCell: SelectionCell!
    
    @IBOutlet weak var submitCell: UITableViewCell!
    @IBOutlet weak var submitLabel: UILabel!
    
    var newRouteMenuEventDelegate: NewRouteMenuEventDelegate!
    
    override func viewDidLoad() {
        submitLabel.textColor = Colors.wsdotPrimary
        definesPresentationContext = false

        // submit diabled until we get two points
        submitLabel.textColor = .gray
        submitCell.isUserInteractionEnabled = false
        
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
