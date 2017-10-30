//
//  UIColorEx.swift
//  LiquidLoading
//
//  Created by Takuma Yoshida on 2015/08/21.
//  Copyright (c) 2015年 yoavlt. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    var Red: CGFloat {
        get {
            let components = self.cgColor.components
            return components![0]
        }
    }
    
    var Green: CGFloat {
        get {
            let components = self.cgColor.components
            return components![1]
        }
    }
    
    var Blue: CGFloat {
        get {
            let components = self.cgColor.components
            return components![2]
        }
    }
    
    var Alpha: CGFloat {
        get {
            return self.cgColor.alpha
        }
    }

    func Alpha(_ alpha: CGFloat) -> UIColor {
        return UIColor(red: self.Red, green: self.Green, blue: self.Blue, alpha: Alpha)
    }
    
    func White(_ scale: CGFloat) -> UIColor {
        return UIColor(
            red: self.Red + (1.0 - self.Red) * scale,
            green: self.Green + (1.0 - self.Green) * scale,
            blue: self.Blue + (1.0 - self.Blue) * scale,
            alpha: 1.0
        )
    }
}
