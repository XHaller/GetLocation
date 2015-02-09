//
//  HudView.swift
//  MyLocations
//
//  Created by BX_mbp on 14/12/8.
//  Copyright (c) 2014年 BX_mbp. All rights reserved.
//

import UIKit

class HudView: UIView {
    var text = ""
    class func hudInView(view:UIView,animated:Bool) -> HudView {
        //a convenience constructor that creates and returns a new HudView instance.
        let hudView = HudView(frame: view.bounds)
        //an init method
        hudView.opaque = false
        view.addSubview(hudView)
        view.userInteractionEnabled = false
        //all the underlying views become unresponsive.
        hudView.showAnimated(animated)
        return hudView
    }
    
    override func drawRect(rect: CGRect) {
        //重画一个view作为hubview
        let boxWidth:CGFloat = 96
        let boxHeight:CGFloat = 96
        //when working with UIKit or CG you use CGFloat.
        let boxRect = CGRect(x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2), width: boxWidth, height: boxHeight)
        //You use it to calculate the position for the HUD.
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        //drawing rectangle with rounded corners.
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        if let image = UIImage(named: "Checkmark"){
            //loads the checkmark image into a UIImage object.
            let imagePoint = CGPoint(
                x:center.x - round(image.size.width / 2),
                y:center.y - round(image.size.height / 2) - boxHeight / 8)
            image.drawAtPoint(imagePoint)
            let attribs = [NSFontAttributeName:UIFont.systemFontOfSize(16.0),
                NSForegroundColorAttributeName: UIColor.whiteColor()]
            //font and color in a dictionary.
            let textSize = text.sizeWithAttributes(attribs)
            let textPoint = CGPoint(
                x:center.x - round(textSize.width / 2),
                y:center.y - round(textSize.height / 2) + boxHeight / 4)
            text.drawAtPoint(textPoint,withAttributes:attribs)
        }
    }
    
    func showAnimated(animated:Bool){
        if animated{
            alpha = 0//making the view fully transparent
            transform = CGAffineTransformMakeScale(1.3, 1.3)
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5,options: UIViewAnimationOptions(0),
                animations:{
                    self.alpha = 1//making the view opaque
                    self.transform = CGAffineTransformIdentity
                },
                completion:nil)
        }
            
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    */

}
