//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by BX_mbp on 15/2/16.
//  Copyright (c) 2015年 BX_mbp. All rights reserved.
//

import UIKit

extension UIImage {
    func resizedImageWithBounds(bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        //等比例缩小
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        //creates a new image context and draws the image into that. 
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        drawInRect(CGRect(origin: CGPoint.zeroPoint, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
