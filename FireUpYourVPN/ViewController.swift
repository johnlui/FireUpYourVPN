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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for i in self.textFieldArray {
            i.resignFirstResponder()
        }
    }
    
    func initDataAndInterface() {
        self.mainButton.disable()
        self.deleteButton.disable()
        
        if Common.sharedUserDefaults?.bool(forKey: "deleted") != true {
            self.deleteButton.setTitle("删除VPN配置", for: UIControlState())
        }
        
        if let configs = Common.sharedUserDefaults?.array(forKey: "configsArray") as? [AnyObject] {
            for (i, j) in self.textFieldArray.enumerated() {
                j.text = configs[i].description
            }
            self.deleteButton.enable()
        }
    }
    
    @IBAction func editingChanged(_ sender: AnyObject) {
        for i in self.textFieldArray {
            if i.notEmpty {
                self.mainButton.enable()
            } else {
                self.mainButton.disable()
            }
        }
    }

    @IBAction func mainButtonBeTapped(_ sender: AnyObject) {
        var valuesArray = [String]()
        for i in self.textFieldArray {
            if let text = i.text {
                valuesArray.append(text)
            }
        }
        if valuesArray.count == 5 {
            Common.sharedUserDefaults?.setValue(valuesArray, forKey: "configsArray")
            Common.sharedUserDefaults?.set(true, forKey: "updated")
            self.noticeSuccess("配置保存成功", autoClear: true, autoClearTime: 3)
        } else {
            self.noticeError("配制保存出错")
        }
    }
    @IBAction func deleteButtonBeTapped(_ sender: AnyObject) {
        Common.sharedUserDefaults?.set(true, forKey: "deleted")
        Common.sharedUserDefaults?.set(false, forKey: "updated")
        if Common.sharedUserDefaults?.bool(forKey: "deleted") == true {
            (sender as? UIButton)?.setTitle("删除请求已发出，请下拉通知栏触发删除", for: UIControlState())
            (sender as? UIButton)?.disable()
        }
    }
    @IBAction func loadConfigButtonBeTapped(_ sender: AnyObject) {
        let alert = UIAlertController(title: "请粘贴URL", message: "请粘贴自动配置文件的URL", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "请粘贴URL"
        }

        alert.addAction(UIAlertAction(title: "载入", style: .default, handler: { (_) in
            let textField = alert.textFields![0]
            let data = try! Data(contentsOf: URL(string: textField.text!)!)
            let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            print(string)
        }))

        self.present(alert, animated: true, completion: nil)
    }
}

private typealias TextFiledDelegate = ViewController

extension TextFiledDelegate: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.textFieldArray.last == textField {
            textField.resignFirstResponder()
        } else {
            self.textFieldArray[self.textFieldArray.index(of: textField)! + 1].becomeFirstResponder()
        }
        return true
    }
}

