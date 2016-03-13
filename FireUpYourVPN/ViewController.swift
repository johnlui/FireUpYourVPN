//
//  ViewController.swift
//  FireUpYourVPN
//
//  Created by 吕文翰 on 15/11/24.
//  Copyright © 2015年 JohnLui. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var textFieldArray: [UITextField]!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textFieldArray.first?.becomeFirstResponder()
        
        self.initDataAndInterface()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for i in self.textFieldArray {
            i.resignFirstResponder()
        }
    }
    
    func initDataAndInterface() {
        self.mainButton.disable()
        self.deleteButton.disable()
        
        if Common.sharedUserDefaults?.boolForKey("deleted") != true {
            self.deleteButton.setTitle("删除VPN配置", forState: .Normal)
        }
        
        if let configs = Common.sharedUserDefaults?.arrayForKey("configsArray") {
            for (i, j) in self.textFieldArray.enumerate() {
                j.text = configs[i].description
            }
            self.deleteButton.enable()
        }
    }
    
    @IBAction func editingChanged(sender: AnyObject) {
        for i in self.textFieldArray {
            if i.notEmpty {
                self.mainButton.enable()
            } else {
                self.mainButton.disable()
            }
        }
    }

    @IBAction func mainButtonBeTapped(sender: AnyObject) {
        var valuesArray = [String]()
        for i in self.textFieldArray {
            if let text = i.text {
                valuesArray.append(text)
            }
        }
        if valuesArray.count == 5 {
            Common.sharedUserDefaults?.setValue(valuesArray, forKey: "configsArray")
            Common.sharedUserDefaults?.setBool(true, forKey: "updated")
            self.noticeSuccess("配置保存成功", autoClear: true, autoClearTime: 3)
        } else {
            self.noticeError("配制保存出错")
        }
    }
    @IBAction func deleteButtonBeTapped(sender: AnyObject) {
        Common.sharedUserDefaults?.setBool(true, forKey: "deleted")
        Common.sharedUserDefaults?.setBool(false, forKey: "updated")
        if Common.sharedUserDefaults?.boolForKey("deleted") == true {
            (sender as? UIButton)?.setTitle("删除请求已发出，请下拉通知栏触发删除", forState: .Normal)
            (sender as? UIButton)?.disable()
        }
    }
}

private typealias TextFiledDelegate = ViewController

extension TextFiledDelegate: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if self.textFieldArray.last == textField {
            textField.resignFirstResponder()
        } else {
            self.textFieldArray[self.textFieldArray.indexOf(textField)! + 1].becomeFirstResponder()
        }
        return true
    }
}

