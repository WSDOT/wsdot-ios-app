//
//  PickerTextField.swift
//  WSDOT
//
//  Created by Logan Sims on 7/25/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

import UIKit

class PickerTextField: UITextField {

    override func caretRectForPosition(position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
    override func selectionRectsForRange(range: UITextRange) -> [AnyObject] {
        return []
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        
        if action == #selector(NSObject.copy(_:)) || action == #selector(NSObject.selectAll) || action == #selector(NSObject.paste) {
            
            return false
            
        }
        
        return super.canPerformAction(action, withSender: sender)
        
    }
}
