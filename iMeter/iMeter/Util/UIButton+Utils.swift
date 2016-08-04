//
//  UIButton+Utils.swift
//  shandui
//
//  Created by Rail on 5/31/16.
//  Copyright © 2016 Rail. All rights reserved.
//

import UIKit

extension UIButton {
    
    func themeButton() {
        enabled = true
        setTitleColor(UIColor.whiteColor(), forState: .Normal)
        backgroundColor = UIColor.buttonColor()
        layer.cornerRadius = 8
    }
    
    func disableBtn() {
        enabled = false
        setTitleColor(UIColor.colorWithHex(0xb7b7b7), forState: .Normal)
        backgroundColor = UIColor.colorWithHex(0xd7d7d7)
        layer.cornerRadius = 8
    }
    
    func whiteBtn() {
        enabled = true
        setTitleColor(UIColor.textColor(), forState: .Normal)
        backgroundColor = UIColor.whiteColor()
        layer.cornerRadius = 8
        
        layer.borderColor = UIColor.themeColor().CGColor
        layer.borderWidth = 1
        
    }
}
