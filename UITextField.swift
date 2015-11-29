//
//  UITextField.swift
//  FireUpYourVPN
//
//  Created by 吕文翰 on 15/11/29.
//  Copyright © 2015年 JohnLui. All rights reserved.
//

import UIKit

extension UITextField {
    var notEmpty: Bool{
        get {
            return self.text != ""
        }
    }
}