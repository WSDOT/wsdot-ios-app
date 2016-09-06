//
//  SR520TollRatesViewController.swift
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

class SR520ViewController: UIViewController {
    
    let cellIdentifier = "threeColCell"

    var data = [ThreeColItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = TollRatesStore.getSR520data()
    }
    
    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! ThreeColTableCell

        cell.colOneLabel.text = data[indexPath.row].colOne
        cell.colTwoLabel.text = data[indexPath.row].colTwo
        cell.colThreeLabel.text = data[indexPath.row].colThree
        
        if (data[indexPath.row].header){
            cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
        } else {
            cell.backgroundColor = UIColor.lightTextColor()
        }
                
        return cell
    }
    
}