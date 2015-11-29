//
//  UIButton.swift
//  FireUpYourVPN
//
//  Created by 吕文翰 on 15/11/29.
//  Copyright © 2015年 JohnLui. All rights reserved.
//

import UIKit

extension UIButton {
    func disable() {
        self.enabled = false
        self.alpha = 0.5
    }
    func enable() {
        self.enabled = true
        self.alpha = 1
    }
}