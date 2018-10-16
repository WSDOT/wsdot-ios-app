//
//  IconButton.swift
//  WSDOT
//
//  Created by Logan Sims on 10/2/18.
//  Copyright © 2018 WSDOT. All rights reserved.
//

import Foundation

class IconButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 8, left: (bounds.width - 24), bottom: 5, right: 5)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: (imageView?.frame.width)! + 8)
        }
    }
}
