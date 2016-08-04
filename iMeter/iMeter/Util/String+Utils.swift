//
//  String+Utils.swift
//  shandui
//
//  Created by Rail on 6/12/16.
//  Copyright © 2016 Rail. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func matchRegular(reg:String) -> Bool {
        let pred = NSPredicate(format: "SELF MATCHES %@", reg)
        
        return pred.evaluateWithObject(self)
    }
    
    func containRegular(reg:String) ->Bool {
        let express = try!NSRegularExpression(pattern: reg, options: .CaseInsensitive)
        let matches = express.matchesInString(self, options: .ReportCompletion, range: NSRange(location: 0, length: characters.count))
        return matches.count > 0
        
    }
    
    func formatPhone() ->String {
        let index1 = startIndex.advancedBy(3)
        let index2 = startIndex.advancedBy(7)
        
        return substringToIndex(index1) + " " + substringWithRange(index1..<index2) + " " + substringFromIndex(index2)
    }
    
    func securityFormatPhone() ->String {
        let index1 = startIndex.advancedBy(3)
        let index2 = startIndex.advancedBy(7)
        
        return substringToIndex(index1) + " **** " + substringFromIndex(index2)
    }
    
    func qrCodeImage() -> UIImage{
        let codeData = dataUsingEncoding(NSUTF8StringEncoding)
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        filter.setDefaults()
        filter.setValue(codeData, forKey: "inputMessage")
        let image = filter.outputImage!
        let size:CGFloat = 250
        let extent = CGRectIntegral(image.extent)
        let scale = min(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent))
        
        let width = Int(CGRectGetWidth(extent) * scale)
        let height = Int(CGRectGetHeight(extent) * scale)
        
        let cs = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, CGImageAlphaInfo.None.rawValue);
        let context = CIContext(options: nil)
        let bitmapImage = context.createCGImage(image, fromRect: extent)
        CGContextSetInterpolationQuality(bitmapRef, CGInterpolationQuality.None)
        CGContextScaleCTM(bitmapRef, scale, scale)
        CGContextDrawImage(bitmapRef, extent, bitmapImage)
        
        let scaledImage = CGBitmapContextCreateImage(bitmapRef)
        
        return UIImage(CGImage: scaledImage!)
    }
    
}