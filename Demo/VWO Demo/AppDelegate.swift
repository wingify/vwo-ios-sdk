//
//  AppDelegate.swift
//  VWO Demo
//
//  Created by Kaunteya Suryawanshi on 29/09/17.
//  Copyright © 2017 Wingify. All rights reserved.
//

import UIKit
import VWO
import SCLAlertView
import MBProgressHUD

let keyVWOApiKey = "VWOApiKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let menuVC = UIStoryboard.main.instantiate(identifier: "menuVC") as MenuVC
    let phoneNav = UIStoryboard.main.instantiate(identifier: "phoneNav") as UINavigationController
    let houseNav = UIStoryboard.main.instantiate(identifier: "houseNav") as UINavigationController

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setCurrentViewController(vc: houseNav)
//        setCurrentViewController(vc: phoneNav)
        return true
    }

    func setCurrentViewController(vc: UIViewController) {
        let slideMenuController = SlideMenuController(mainViewController: vc, leftMenuViewController: menuVC)
        menuVC.delegate = self
        window?.rootViewController = slideMenuController
        window?.makeKeyAndVisible()
    }

}

extension AppDelegate: HamburgerMenuDelegate {

    func selectedMenuItem(item: HamburgerMenuItem) {
        print("Item \(item)")
        switch item {
        case .sortingCampaign: setCurrentViewController(vc: phoneNav)
        case .variableCampaign: setCurrentViewController(vc: houseNav)
        case .about:
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
            SCLAlertView().showInfo("Version: \(version)(\(build))", subTitle: "")
        case .apiKey:
            let _ = 1
            APIKeyManager.showAlert()
        }
    }
}
