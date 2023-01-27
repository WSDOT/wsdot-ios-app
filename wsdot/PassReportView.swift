//
//  PassReportView.swift
//  WSDOT
//
//  Created by Logan on 10/23/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//

import UIKit

class PassReportView: UIView {
    
    @IBOutlet weak var mountainPassTitle: UILabel!
    
    @IBOutlet weak var mountainPassTitleLabel: UILabel!
    
    @IBOutlet weak var mountainPassIconStack: UIStackView!
    @IBOutlet weak var mountainPassIconImage: UIImageView!
    @IBOutlet weak var mountainPassIconLabel: UILabel!
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var restrictionOneLabel: UILabel!
    
    @IBOutlet weak var restrictionTwoLabel: UILabel!
    
    @IBOutlet weak var conditionsLabel: UILabel!
    
    @IBOutlet weak var weatherDetailsLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var elevationLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        myInit()
    }
    
    required init?(coder aDecorder: NSCoder) {
        super.init(coder: aDecorder)
        myInit()
    }
    
    private func myInit() {
        
        Bundle.main.loadNibNamed("PassReportView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        
    }

}
