//
//  405TollTripView.swift
//  WSDOT
//
//  Created by Logan Sims on 7/20/18.
//  Copyright © 2018 WSDOT. All rights reserved.
//

import UIKit

class TollTrip405View: UIView {
    
    private let negativeLineRightPadding: CGFloat = -24.0
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var line: UIView!

    static func instantiateFromXib() -> TollTrip405View {
        return Bundle.main.loadNibNamed("TollTrip405View", owner: nil, options: nil)![0] as! TollTrip405View
    }

}
