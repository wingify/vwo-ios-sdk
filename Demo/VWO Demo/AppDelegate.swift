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

    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    lazy var menuVC = storyboard.instantiateViewController(withIdentifier: "menuVC") as! MenuVC
    lazy var phoneNav = storyboard.instantiateViewController(withIdentifier: "phoneNav") as! UINavigationController
    lazy var houseNav = storyboard.instantiateViewController(withIdentifier: "houseNav") as! UINavigationController
    lazy var slideMenuController = SlideMenuController(mainViewController: phoneNav, leftMenuViewController: menuVC)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        menuVC.delegate = self
        window?.rootViewController = slideMenuController
        window?.makeKeyAndVisible()

        return true
    }

    private func launchVWO(_ apiKey : String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
            let slideVC = self.window!.rootViewController as! SlideMenuController
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
        switch item {
        case .sortingCampaign:
            slideMenuController.mainViewController = phoneNav
        case .variableCampaign:
            slideMenuController.mainViewController = houseNav
        default: break
        }
    }
}
