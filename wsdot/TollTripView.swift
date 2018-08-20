//
//  405TollTripView.swift
//  WSDOT
//
//  Created by Logan Sims on 7/20/18.
//  Copyright © 2018 WSDOT. All rights reserved.
//

import UIKit

class TollTripView: UIView {
    
    private let negativeLineRightPadding: CGFloat = -24.0
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var actionButton: TripMapButton!
    @IBOutlet weak var line: UIView!

    static func instantiateFromXib() -> TollTripView {
        return Bundle.main.loadNibNamed("TollTripView", owner: nil, options: nil)![0] as! TollTripView
    }
}

class TripMapButton: UIButton {

    var signIndex: Int?
    var tripIndex: Int?

}
