//
//  TodayViewController.swift
//  Today
//
//  Created by 吕文翰 on 15/11/24.
//  Copyright © 2015年 JohnLui. All rights reserved.
//

import UIKit
import NotificationCenter
import NetworkExtension

struct VPNConfig {
    var server: String!
    var username: String!
    var password: String!
    var groupName: String!
    var sharedSecret: String!
}

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var manager: NEVPNManager!
    var vpnConfig: VPNConfig!
    
    @IBOutlet weak var juhuaView: UIActivityIndicatorView!
    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var notConfiguredLabel: UILabel!
    @IBOutlet weak var deletedSuccessLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let configsArray = Common.sharedUserDefaults?.array(forKey: "configsArray") as? [AnyObject] {
            self.vpnConfig = VPNConfig(server: configsArray[0].description, username: configsArray[1].description, password: configsArray[2].description, groupName: configsArray[3].description, sharedSecret: configsArray[4].description)
        } else {
            return self.notConfiguredLabel.isHidden = false
        }
        
        self.manager = NEVPNManager.shared()
        self.manager.loadFromPreferences { (error) -> Void in
            if Common.sharedUserDefaults?.bool(forKey: "deleted") == true {
                self.manager.removeFromPreferences(completionHandler: { (error) -> Void in
                    Common.sharedUserDefaults?.removeObject(forKey: "deleted")
                    return self.deletedSuccessLabel.isHidden = false
                })
            }
            if Common.sharedUserDefaults?.bool(forKey: "updated") == true {
                self.manager.removeFromPreferences { (error) -> Void in
                    self.addPersonalVPNConfig()
                    Common.sharedUserDefaults?.removeObject(forKey: "updated")
                }
            }
            if self.manager.`protocol` == nil {
                self.addPersonalVPNConfig()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.juhuaView.isHidden = true
        if let _ = self.manager {
            NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: self.manager.connection, queue: OperationQueue.main) { (notification) -> Void in
                if self.manager.connection.status == .connecting {
                    self.juhuaView.isHidden = false
                    print("show")
                } else {
                    self.juhuaView.isHidden = true
                    print("hide")
                }
                self.refreshSwitch()
            }
            self.refreshSwitch()
        }
    }
    
    func refreshSwitch() {
        self.`switch`.setOn(self.manager.connection.status == .connected, animated: false)
    }
    
    func addPersonalVPNConfig() {
        let keychain = Keychain(service: "com.lvwenhan.FireYourVPN")
        keychain["password"] = self.vpnConfig.password
        keychain["sharedSecret"] = self.vpnConfig.sharedSecret
        
        let v2 = NEVPNProtocolIPSec()
        v2.authenticationMethod = NEVPNIKEAuthenticationMethod.none
        v2.useExtendedAuthentication = true
        v2.serverAddress = self.vpnConfig.server
        
        self.manager.localizedDescription = "Fire Up VPN Today"
        
        v2.localIdentifier = self.vpnConfig.groupName
        
        v2.username = self.vpnConfig.username
        v2.passwordReference = keychain[attributes: "password"]!.persistentRef as Data?
        
        v2.authenticationMethod = NEVPNIKEAuthenticationMethod.sharedSecret
        v2.sharedSecretReference = keychain[attributes: "sharedSecret"]!.persistentRef as Data?
        
        self.manager.`protocol` = v2
        self.manager.isEnabled = true
        self.manager.saveToPreferences(completionHandler: { (error) -> Void in
            if let _ = error {
                print("Save Error: ", error)
            }
            do {
                try NEVPNManager.shared().connection.startVPNTunnel()
            } catch {
                print("Fire Up Error: ", error)
            }
        })

    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        var newMargins = defaultMarginInsets
        newMargins.left = 15
        newMargins.right = 15
        newMargins.bottom = 0
        return newMargins
    }
    @IBAction func switchBeSwiched(_ sender: AnyObject) {
        if self.manager.`protocol` != nil {
            if let a = sender as? UISwitch {
                if a.isOn {
                    if self.manager.connection.status == .disconnected {
                        do {
                            try self.manager.connection.startVPNTunnel()
                        } catch {
                            print("Fire Up Error: ", error)
                        }
                    }
                } else {
                    self.manager.connection.stopVPNTunnel()
                }
            }
        } else {
            print("设置出错")
        }
    }
    
}
