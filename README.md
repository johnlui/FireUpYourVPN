在通知中心一键启用 VPN
----------

### 基础要求：

* Xcode 7+ / Swift 2.0+
* iOS 8+
* 付费苹果开发者账号（用于 VPN）

### 使用展示

下拉：

![screenshot-1](https://raw.githubusercontent.com/johnlui/FireUpYourVPN/master/images/screenshot-1.jpg)

点击连接：

![screenshot-2](https://raw.githubusercontent.com/johnlui/FireUpYourVPN/master/images/screenshot-2.jpg)

连接成功：

![screenshot-3](https://raw.githubusercontent.com/johnlui/FireUpYourVPN/master/images/screenshot-3.jpg)

### 关键特性

alpha 1.0，暂时只支持 CISCO IPSec。

修改配置，TodayViewController 中：

```swift
self.vpnConfig = VPNConfig(server: "www.ooxx.com", username: "user", password: "pass", groupName: "vpn", sharedSecret: "vpn.psk")
```

### 关键设置

![fix-xcode-config](https://raw.githubusercontent.com/johnlui/FireUpYourVPN/master/images/fix-xcode-config.png)

## 参与开源

欢迎提交 issue 和 PR，大门永远向所有人敞开。

## 开源协议

本项目遵循 MIT 协议开源，具体请插件根目录下的 LICENSE 文件。