
//
//  UIControls.swift
//  WWDC
//
//  Created by Laurent Mihalkovic on 3/23/16.
//  Copyright © 2016 Laurent Mihalkovic. All rights reserved.
//

import UIKit

// TODO: rewrite

let BTNCOLOR = UIColor(red:0.527, green:0.512, blue:0.494, alpha:1);
// let BTNCOLOR = UIColor(red:0.449, green:0.441, blue:0.410, alpha:1);
// let BTNCOLOR = UIColor(red:0.576, green:0.580, blue:0.600, alpha:1);

extension UIButton {

    func showSystemAppearance() {
        backgroundColor = BTNCOLOR;
        tintColor = UIColor.whiteColor()
//        tintColor = UIColor(red:0.576, green:0.580, blue:0.600, alpha:1);
        layer.cornerRadius = 8;
    }
  
    func showFocusOn() {
        let defaultTint = self.superview?.tintColor
        
        self.backgroundColor = defaultTint;
        self.tintColor = UIColor.blackColor();
//        self.tintColor = UIColor.whiteColor();
        
        //Add Shadow
        layer.shadowOffset = CGSizeMake(0, 10);
        layer.shadowOpacity = 0.6;
        layer.shadowRadius = 15;
        layer.shadowColor = UIColor.blackColor().CGColor;
        
        //Scale Up
        UIView.beginAnimations("button", context:nil);
        UIView.setAnimationDuration(0.3);
        self.transform = CGAffineTransformMakeScale(1.15, 1.15);
        UIView.commitAnimations();
        
    }
    
    func showFocusOff() {
        backgroundColor = BTNCOLOR;
        tintColor = UIColor.whiteColor()
        
        //Remove Shadow
        layer.shadowOpacity = 0;
        
        //Scale down
        UIView.beginAnimations("button", context:nil);
        UIView.setAnimationDuration(0.35);
        transform = CGAffineTransformIdentity;
        UIView.commitAnimations();
    }
  
}
