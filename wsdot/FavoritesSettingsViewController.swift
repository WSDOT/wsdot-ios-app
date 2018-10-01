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
    let textCellIdentifier = "TextCell"
    
    let numFavoriteSections = 7
    
    var sectionTypesOrderRawArray = UserDefaults.standard.array(forKey: UserDefaultsKeys.favoritesOrder) as? [Int] ?? [Int]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        GoogleAnalytics.screenView(screenName: "/Favorites/Settings")
    }
    
    func clearFavorites(){
    
        GoogleAnalytics.event(category: "Favorites", action: "UIAction", label: "Cleared Favorites")
        
        for camera in CamerasStore.getFavoriteCameras() {
            CamerasStore.updateFavorite(camera, newValue: false)
        }
        for time in TravelTimesStore.findFavoriteTimes() {
            TravelTimesStore.updateFavorite(time, newValue: false)
        }
        for schedule in FerryRealmStore.findFavoriteSchedules() {
            FerryRealmStore.updateFavorite(schedule, newValue: false)
        }
        for pass in MountainPassStore.findFavoritePasses() {
            MountainPassStore.updateFavorite(pass, newValue: false)
        }
        for location in FavoriteLocationStore.getFavorites() {
            FavoriteLocationStore.deleteFavorite(location)
        }
        for route in MyRouteStore.getSelectedRoutes() {
            _ = MyRouteStore.updateSelected(route, newValue: false)
        }
        for toll in TollRatesStore.findFavoriteTolls() {
            TollRatesStore.updateFavorite(toll, newValue: false)
        }
    }
    
}

// MARK: - TableView

extension FavoritesSettingsViewController:  UITableViewDataSource, UITableViewDelegate {


    func numberOfSections(in tableView: UITableView) -> Int {
    
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "Organize Favorites"
            case 1:
                return ""
            default:
                return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return numFavoriteSections
            case 1:
                return 1
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
        
            let deleteCell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
            deleteCell.textLabel?.text = "Clear Favorites"
            deleteCell.textLabel?.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
            
            deleteCell.textLabel?.textAlignment = .center
            
            
            return deleteCell
            
            
        default:
            return tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
        }
    }
    
    // MARK: - Navigation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        case 1: // Delete

            let alertController = UIAlertController(title: "Clear Favorites?", message:"This cannot be undone. Any saved map locations will be deleted. Recorded routes will be kept.", preferredStyle: .alert)

            // Setting tintColor on iOS < 9 leades to strange display behavior.
            if #available(iOS 9.0, *) {
                alertController.view.tintColor = Colors.tintColor
            }

            let confirmDeleteAction = UIAlertAction(title: "Clear", style: .destructive) { (_) -> Void in
                self.clearFavorites()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(confirmDeleteAction)
            
            present(alertController, animated: false, completion: nil)

            tableView.deselectRow(at: indexPath, animated: true)
            break
        default:
            break
        }
    }
    
    // MARK: - Edit
    
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        // Update title array
        let sectionMoved = sectionTypesOrderRawArray.remove(at: fromIndexPath.row)
        sectionTypesOrderRawArray.insert(sectionMoved, at: toIndexPath.row)
        UserDefaults.standard.set(sectionTypesOrderRawArray, forKey: UserDefaultsKeys.favoritesOrder)
    }
}

