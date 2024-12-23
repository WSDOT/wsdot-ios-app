//
//  RouteView.swift
//  WSDOT
//
//  Created by Logan Sims on 6/27/18.
//  Copyright © 2018 WSDOT. All rights reserved.
//

import UIKit

class RouteView: UIView {
    
    private let negativeLineRightPadding: CGFloat = -24.0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var updatedLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var mapButton: TravelTimeMapButton!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var line: UIView!

    static func instantiateFromXib() -> RouteView {
        return Bundle.main.loadNibNamed("RouteView", owner: nil, options: nil)![0] as! RouteView
    }

}

class TravelTimeMapButton: UIButton {

    var routeIndex: Int?
    var travelTimeIndex: Int?

}
