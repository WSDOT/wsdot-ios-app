//
//  DeparturesCustomCell.swift
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

class DeparturesCustomCell: UITableViewCell {
    
    @IBOutlet weak var etaLabel: UILabel!
    
    @IBOutlet weak var departingTimeBox: UIView!
    @IBOutlet weak var departingTime: UILabel!
    @IBOutlet weak var departingTimeLabel: UILabel!
    
    @IBOutlet weak var arrivingTimeBox: UIView!
    @IBOutlet weak var arrivingTime: UILabel!
    @IBOutlet weak var arrivingTimeLabel: UILabel!
    
    
    @IBOutlet weak var sailingSpaces: UILabel!
    @IBOutlet weak var actualDepartureLabel: UILabel!
    
    
    @IBOutlet weak var vesselAtDockLabel: INDLinkLabel!
    
    @IBOutlet weak var annotations: INDLinkLabel!
    @IBOutlet weak var avaliableSpacesBar: UIProgressView!
    @IBOutlet weak var spacesDisclaimer: UILabel!
    
    
    @IBOutlet weak var deptAndETAStack: UIStackView!
    @IBOutlet weak var annotationsStack: UIStackView!
    @IBOutlet weak var spacesStack: UIStackView!
}
