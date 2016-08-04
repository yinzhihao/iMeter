//
//  UIColor+Utils.swift
//  SweetCoffee
//
//  Created by Rail on 16/3/16.
//  Copyright © 2016年 Rail. All rights reserved.
//

import UIKit

extension UIColor {
    
    public class func colorWithHex(hexValue:UInt32, alpha:CGFloat) -> UIColor {
        return UIColor(red: (CGFloat)((hexValue & 0xFF0000) >> 16) / 255.0,
                       green: (CGFloat)((hexValue & 0xFF00) >> 8) / 255.0,
                       blue: (CGFloat)(hexValue & 0xFF) / 255.0,
                       alpha: alpha)
    }
    
    public class func colorWithHex(hexValue:UInt32) -> UIColor {
        return colorWithHex(hexValue, alpha: 1.0);
    }
    
    public class func themeColor() -> UIColor {
        return colorWithHex(0x167bc1);
    }
    
    public class func buttonColor() -> UIColor {
        return colorWithHex(0x167bc1)
    }
    
    public class func buttonDisableTextColor() -> UIColor {
        return colorWithHex(0x73b3e1)
    }
    
    public class func backColor() -> UIColor {
        return colorWithHex(0xefeef4)
    }
    
    public class func warnColor() -> UIColor{
        return colorWithHex(0xe8442e)
    }
    
    public class func textColor() -> UIColor{
        return colorWithHex(0x333333)
    }
    public class func textLightColor() -> UIColor{
        return colorWithHex(0x666666)
    }
    
    public class func imageFromColor(color:UIColor, size:CGSize) -> UIImage{
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
