//
//  LaunchVWO.swift
//  VWO Demo
//
//  Created by Kaunteya Suryawanshi on 24/07/18.
//  Copyright © 2018-2022 Wingify. All rights reserved.
//

import UIKit
import VWO
import MBProgressHUD
import SCLAlertView

class VWOManager {
    class func launch(_ apiKey: String) {
        guard let hudParentView = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.view else {
            return
        }
        let hud = MBProgressHUD.showAdded(to: hudParentView, animated: true)
        hud.label.text = "Launching VWO-\(VWO.version())"

        VWO.logLevel = .debug
        let config = VWOConfig()
//        config.setCustomDimension(customDimensionKey: "userId", customDimensionValue: "userName")
//        config.userID = "9c3832ad-15f9-420a-93cd-a7f2cde0f7bc"
//        config.isChinaCDN = false
        VWO.launch(apiKey: apiKey, config: config, completion: {
            DispatchQueue.main.async {
               
//                VWO.pushCustomDimension(customDimensionKey: "userId", customDimensionValue: "userName")
                hud.hide(animated: false)
                SCLAlertView().showSuccess("Success", subTitle: "VWO launched successfully \(apiKey)")
                var str: String? = nil;
                VWO.variationNameFor(testKey: str ?? "")
                VWO.trackConversion("", value: 10.0)
                
            }
        }, failure: { (errorString) in
            DispatchQueue.main.async {
                hud.hide(animated: false)
                SCLAlertView().showError("Error", subTitle: errorString)
            }
        })
    }
}
