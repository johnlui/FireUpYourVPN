//
//  CALayer.swift
//  FireUpYourVPN
//
//  Created by 吕文翰 on 15/11/28.
//  Copyright © 2015年 JohnLui. All rights reserved.
//

import UIKit

extension CALayer {
    var borderUIColor: UIColor {
        get {
            return UIColor(cgColor: self.borderColor!)
        }
        set {
            self.borderColor = newValue.cgColor
        }
    }
}
