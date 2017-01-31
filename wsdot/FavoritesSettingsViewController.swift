//
//  FavoritesSettingsViewController.swift
//  WSDOT
//
//  Copyright (c) 2017 Washington State Department of Transportation
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

class FavoritesSettingsViewController: UIViewController {

    let sectionCellIdentifier = "SectionCell"
    let routeCellIdentifier = "RouteCell"
    
    let numFavoriteSections = 6
    
    var sectionTypesOrderRawArray = UserDefaults.standard.array(forKey: UserDefaultsKeys.favoritesOrder) as? [Int] ?? [Int]()
    
    var myRoutes = MyRouteStore.getRoutes()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
    }
    
    func setRoute(sender: UIButton) {
        _ = MyRouteStore.setSelected(myRoutes[sender.tag])
        tableView.reloadData()
    }
    
    func deleteRoute(sender: UIButton){
        let alertController = UIAlertController(title: "Are you sure you want to delete this route?", message:"This cannot be undone.", preferredStyle: .alert)

        alertController.view.tintColor = Colors.tintColor

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) -> Void in
            
            _ = MyRouteStore.delete(route: self.myRoutes.remove(at: sender.tag))
            self.tableView.reloadData()
            
        }
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
            
        self.present(alertController, animated: false, completion: nil)
    
    }
}

// MARK: - TableView

extension FavoritesSettingsViewController:  UITableViewDataSource, UITableViewDelegate {


    func numberOfSections(in tableView: UITableView) -> Int {
    
        var numSections = 1
    
        numSections += myRoutes.count != 0 ? 1 : 0
    
        return numSections
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "Organize Favorites"
            case 1:
                return "Manage Saved Routes"
            default:
                return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return numFavoriteSections
            case 1:
                return myRoutes.count
            default:
                return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        
        case 0:
            let sectionCell = tableView.dequeueReusableCell(withIdentifier: sectionCellIdentifier, for: indexPath)
            
            sectionCell.textLabel?.text = MyRouteStore.sectionTitles[sectionTypesOrderRawArray[indexPath.row]]
            
            return sectionCell
            
        case 1:
        
            let routeCell = tableView.dequeueReusableCell(withIdentifier: routeCellIdentifier, for: indexPath) as! MyRouteSettingsCell
            
            routeCell.titleLabel.text = myRoutes[indexPath.row].name
            
            routeCell.setButton.layer.cornerRadius = 5
            
            if myRoutes[indexPath.row].selected {
                routeCell.setButton.layer.borderColor = Colors.tintColor.cgColor
                routeCell.setButton.backgroundColor = Colors.tintColor
                routeCell.setButton.tintColor = UIColor.white
            } else {
                routeCell.setButton.layer.borderColor = UIColor.clear.cgColor
                routeCell.setButton.backgroundColor = UIColor.clear
                routeCell.setButton.tintColor = Colors.tintColor
            }
            
            routeCell.setButton.tag = indexPath.row
            routeCell.setButton.addTarget(self, action:#selector(FavoritesSettingsViewController.setRoute), for: .touchUpInside)
            
            routeCell.deleteButton.tag = indexPath.row
            routeCell.deleteButton.addTarget(self, action:#selector(FavoritesSettingsViewController.deleteRoute), for: .touchUpInside)
            
            return routeCell
            
        default:
            return tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section){
        case 1:
            _ = MyRouteStore.setSelected(myRoutes[indexPath.row])
            tableView.reloadData()
            tableView.deselectRow(at: indexPath, animated: true)
            break
        default:
            break
        }
    }
    
    // Keep movable cells in their section
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
            }
            return IndexPath(row: row, section: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        // Update title array
        let sectionMoved = sectionTypesOrderRawArray.remove(at: fromIndexPath.row)
        sectionTypesOrderRawArray.insert(sectionMoved, at: toIndexPath.row)
        UserDefaults.standard.set(sectionTypesOrderRawArray, forKey: UserDefaultsKeys.favoritesOrder)
    }
}
