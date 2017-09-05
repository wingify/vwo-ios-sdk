//
//  AppDelegate.swift
//  VWODemoApp
//
//  Created by Kaunteya Suryawanshi on 25/07/17.
//  Copyright © 2017 Wingify. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
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
            launchVWO(apiKey)
        }

        return true
    }

    private func launchVWO(_ apiKey : String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
            let slideVC = self.window!.rootViewController as! SlideMenuController
            let container = slideVC.mainViewController as! ContainerVC
            container.activityIndicator.startAnimating()
            VWO.logLevel = .debug
            VWO.launch(apiKey: apiKey) {
                container.activityIndicator.stopAnimating()
                Swift.print("VWO launched in demo app")
            }
        }
    }

    private func createSlideViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuVC = storyboard.instantiateViewController(withIdentifier: "menuVC") as! MenuVC
        let containerVC = storyboard.instantiateViewController(withIdentifier: "container") as! ContainerVC

        let slideMenuController = SlideMenuController(mainViewController: containerVC, leftMenuViewController: menuVC)
        window?.rootViewController = slideMenuController
        window?.makeKeyAndVisible()
    }
}

