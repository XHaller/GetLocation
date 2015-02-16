//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by BX_mbp on 15/2/16.
//  Copyright (c) 2015年 BX_mbp. All rights reserved.
//

import UIKit
class MyTabBarController: UITabBarController {
    //only overrode preferredStatusBarStyle() to change the status bar color.
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return nil
    }
}
