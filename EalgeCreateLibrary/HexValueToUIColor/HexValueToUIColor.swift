//
//  UIColorHex.swift
//  ZhaiDou
//
//  Created by eagle on 14/12/10.
//  Copyright (c) 2014年 东升. All rights reserved.
//

import UIKit
extension UIColor{
    //颜色转换
    
    class func colorWithHexString(colorString:NSString)->UIColor{
        
        var cString:NSString = colorString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString

        if(cString.length < 6)
        {
            return UIColor.clearColor()
        }

        if cString.hasPrefix("0X")
        {
            cString = cString.substringFromIndex(2)
        }
        
        if cString.hasPrefix("#")
        {
            cString = cString.substringFromIndex(1)
        }
    
        
        
        if cString.length != 6
        {
            return UIColor.clearColor()
        }
        
        var range:NSRange = NSMakeRange(0, 2)
        
        
        // r
        let rString:NSString = cString.substringWithRange(range)
        
        // g
        range.location = 2
        let gString:NSString = cString.substringWithRange(range)
        
        // b
        range.location = 4
        let bString:NSString = cString.substringWithRange(range)
        
        //scan values
        var r:UInt32 = 0
        var g:UInt32 = 0
        var b:UInt32 = 0
        
        let rScanner = NSScanner(string: rString as String)
        rScanner.scanHexInt(&r)
        
        let gScanner = NSScanner(string: gString as String)
        gScanner.scanHexInt(&g)
        
        let bScanner = NSScanner(string: bString as String)
        bScanner.scanHexInt(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
    }
    
    
    

}