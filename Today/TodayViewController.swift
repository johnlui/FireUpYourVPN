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
        
        if let configsArray = Common.sharedUserDefaults?.arrayForKey("configsArray") {
            self.vpnConfig = VPNConfig(server: configsArray[0].description, username: configsArray[1].description, password: configsArray[2].description, groupName: configsArray[3].description, sharedSecret: configsArray[4].description)
        } else {
            return self.notConfiguredLabel.hidden = false
        }
        
        self.manager = NEVPNManager.sharedManager()
        self.manager.loadFromPreferencesWithCompletionHandler { (error) -> Void in
            if Common.sharedUserDefaults?.boolForKey("deleted") == true {
                self.manager.removeFromPreferencesWithCompletionHandler({ (error) -> Void in
                    Common.sharedUserDefaults?.removeObjectForKey("deleted")
                    return self.deletedSuccessLabel.hidden = false
                })
            }
            if Common.sharedUserDefaults?.boolForKey("updated") == true {
                self.manager.removeFromPreferencesWithCompletionHandler { (error) -> Void in
                    self.addPersonalVPNConfig()
                    Common.sharedUserDefaults?.removeObjectForKey("updated")
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.juhuaView.hidden = true
        if let _ = self.manager {
            NSNotificationCenter.defaultCenter().addObserverForName(NEVPNStatusDidChangeNotification, object: self.manager.connection, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
                if self.manager.connection.status == .Connecting {
                    self.juhuaView.hidden = false
                    print("show")
                } else {
                    self.juhuaView.hidden = true
                    print("hide")
                }
                self.refreshSwitch()
            }
            self.refreshSwitch()
        }
    }
    
    func refreshSwitch() {
        self.`switch`.setOn(self.manager.connection.status == .Connected, animated: false)
    }
    
    func addPersonalVPNConfig() {
        let keychain = Keychain(service: "com.lvwenhan.FireYourVPN")
        keychain["password"] = self.vpnConfig.password
        keychain["sharedSecret"] = self.vpnConfig.sharedSecret
        
        let v2 = NEVPNProtocolIPSec()
        v2.authenticationMethod = NEVPNIKEAuthenticationMethod.None
        v2.useExtendedAuthentication = true
        v2.serverAddress = self.vpnConfig.server
        
        self.manager.localizedDescription = "Fire Up VPN Today"
        
        v2.localIdentifier = self.vpnConfig.groupName
        
        v2.username = self.vpnConfig.username
        v2.passwordReference = keychain[attributes: "password"]!.persistentRef
        
        v2.authenticationMethod = NEVPNIKEAuthenticationMethod.SharedSecret
        v2.sharedSecretReference = keychain[attributes: "sharedSecret"]!.persistentRef
        
        self.manager.`protocol` = v2
        self.manager.enabled = true
        self.manager.saveToPreferencesWithCompletionHandler({ (error) -> Void in
            if let _ = error {
                print("Save Error: ", error)
            }
            do {
                try NEVPNManager.sharedManager().connection.startVPNTunnel()
            } catch {
                print("Fire Up Error: ", error)
            }
        })

    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.NewData)
    }
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        var newMargins = defaultMarginInsets
        newMargins.left = 15
        newMargins.right = 15
        newMargins.bottom = 0
        return newMargins
    }
    @IBAction func switchBeSwiched(sender: AnyObject) {
        if self.manager.`protocol` != nil {
            if let a = sender as? UISwitch {
                if a.on {
                    if self.manager.connection.status == .Disconnected {
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