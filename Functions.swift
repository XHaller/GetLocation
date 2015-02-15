//
//  Functions.swift
//  MyLocations
//
//  Created by BX_mbp on 14/12/8.
//  Copyright (c) 2014年 BX_mbp. All rights reserved.
//

import Foundation
import Dispatch
func afterDelay(seconds:Double,closure:()->()){//free function
    let when = dispatch_time(DISPATCH_TIME_NOW,Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue(), closure)
}

let applicationDocumentsDirectory: String = {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
    return paths[0]
}()