//
//  AppDelegate.swift
//  VWO Demo
//
//  Created by Kaunteya Suryawanshi on 29/09/17.
//  Copyright © 2017 Wingify. All rights reserved.
//

import UIKit
import VWO

let keyVWOApiKey = "VWOApiKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let menuVC = UIStoryboard.main.instantiate(identifier: "menuVC") as MenuVC
    let phoneNav = UIStoryboard.main.instantiate(identifier: "phoneNav") as UINavigationController
    let houseNav = UIStoryboard.main.instantiate(identifier: "houseNav") as UINavigationController

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setCurrentViewController(vc: houseNav)
        return true
    }

    func setCurrentViewController(vc: UIViewController) {
        let slideMenuController = SlideMenuController(mainViewController: vc, leftMenuViewController: menuVC)
        menuVC.delegate = self
        window?.rootViewController = slideMenuController
        window?.makeKeyAndVisible()
    }
    private func launchVWO(_ apiKey : String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
//            let slideVC = self.window!.rootViewController as! SlideMenuController
//            let container = slideVC.mainViewController as! ContainerVC
//            container.activityIndicator.startAnimating()
            VWO.logLevel = .debug
            UserDefaults.standard.set(true, forKey: "vwo.enableSocket")
            Swift.print("Launching VWO-\(VWO.version())")


            VWO.launch(apiKey: apiKey, config: nil, completion: {
                DispatchQueue.main.async {
//                    container.activityIndicator.stopAnimating()
//                    container.navigationActionReloadClicked()
                }
                Swift.print("VWO launched in demo app")
            }, failure: { (errorString) in
                DispatchQueue.main.async {
//                    container.activityIndicator.stopAnimating()
                }
                Swift.print("Failed \(errorString)")
            })
        }
    }
}

extension AppDelegate: HamburgerMenuDelegate {
    func selectedMenuItem(item: HamburgerMenuItem) {
        print("Item \(item)")
        switch item {
        case .sortingCampaign:
            setCurrentViewController(vc: phoneNav)
        case .variableCampaign:
            setCurrentViewController(vc: houseNav)
        default: break
        }
    }
}
