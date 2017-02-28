//
//  UIImageEx.swift
//  XCBusiness
//
//  Created by Cstars on 2017/2/20.
//  Copyright © 2017年 xincheng.tv. All rights reserved.
//

import UIKit

extension UIImage {
    /**
     - parameter color: A color.
     - returns: A 1x1 UIImage of a solid color.
     */
    public static func pixel(ofColor color: UIColor) -> UIImage {
        let pixel = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        
        UIGraphicsBeginImageContext(pixel.size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        
        context.setFillColor(color.cgColor)
        context.fill(pixel)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}
