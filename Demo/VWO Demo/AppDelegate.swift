//
//  AppDelegate.swift
//  VWO Demo
//
//  Created by Kaunteya Suryawanshi on 29/09/17.
//  Copyright © 2017-2022 Wingify. All rights reserved.
//

import UIKit
import VWO
import SCLAlertView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let menuVC = UIStoryboard.main.instantiate(identifier: "menuVC") as MenuVC
    let phoneNav = UIStoryboard.main.instantiate(identifier: "phoneNav") as UINavigationController
    let houseNav = UIStoryboard.main.instantiate(identifier: "houseNav") as UINavigationController

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        setCurrentViewController(vc: houseNav)
        setCurrentViewController(vc: phoneNav)

        
        VWOManager.launch("0d79211ecda15f4036cc33351943f1c8-780027")
        
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
        switch item {
        case .sortingCampaign: setCurrentViewController(vc: phoneNav)

        case .variableCampaign: setCurrentViewController(vc: houseNav)

        case .about:
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
            SCLAlertView().showInfo("App Version: \(version)(\(build))", subTitle: "VWO version \(VWO.version())")

        case .apiKey:
            APIKeyManager.showAlert()
        }
    }
}
