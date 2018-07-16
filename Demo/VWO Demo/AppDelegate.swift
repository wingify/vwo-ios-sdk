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

    var viewControllers = [UIInputViewController]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        createSlideViewController()
        VWO.logLevel = .debug
        if let apiKey = UserDefaults.standard.string(forKey: keyVWOApiKey) {
            UserDefaults.standard.set(apiKey, forKey: keyVWOApiKey)
            launchVWO(apiKey)
        }

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

    private func createSlideViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuVC = storyboard.instantiateViewController(withIdentifier: "menuVC") as! MenuVC
//        let containerVC = storyboard.instantiateViewController(withIdentifier: "container") as! ContainerVC
        let nav = storyboard.instantiateViewController(withIdentifier: "navController") as! UINavigationController
//        let phoneListVC = storyboard.instantiateViewController(withIdentifier: "phoneListVC") as! PhoneListVC

        let slideMenuController = SlideMenuController(mainViewController: nav, leftMenuViewController: menuVC)
        window?.rootViewController = slideMenuController
        window?.makeKeyAndVisible()
    }
}

