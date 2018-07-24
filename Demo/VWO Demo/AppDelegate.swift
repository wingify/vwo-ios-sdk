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

    private func launchVWO(_ apiKey : String) {
        let hud = MBProgressHUD.showAdded(to: self.window!.rootViewController!.view, animated: true)
        hud.label.text = "Launching VWO"

        VWO.logLevel = .debug
        Swift.print("Launching VWO-\(VWO.version())")

        VWO.launch(apiKey: apiKey, config: nil, completion: {
            DispatchQueue.main.async {
                hud.hide(animated: false)
                SCLAlertView().showSuccess("Success", subTitle: "VWO launched successfully \(apiKey)")
            }
        }, failure: { (errorString) in
            DispatchQueue.main.async {
                hud.hide(animated: false)
                SCLAlertView().showError("Error", subTitle: errorString)
            }
        })
    }
}

extension AppDelegate: HamburgerMenuDelegate {
    ///Key must be in format `[32Chars]-[NUMS]`
    private func isValid(apiKey: String) -> Bool {
        let keyAnduserId = apiKey.components(separatedBy: "-")
        guard keyAnduserId.count == 2 else {
            return false
        }
        guard keyAnduserId.first?.count == 32 else {
            return false
        }
        guard Int(keyAnduserId[1]) != nil else {
            return false
        }
        return true
    }

    func getAPIKeyForPlaceholder() -> String? {
        if let clipboard = UIPasteboard.general.string,
            isValid(apiKey: clipboard) {
            return clipboard
        }
        if let value = UserDefaults.standard.string(forKey: keyVWOApiKey) {
            return value
        }
        return nil
    }

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
            let alert = SCLAlertView()
            let APIkey = alert.addTextField("Enter API key")
            APIkey.text = getAPIKeyForPlaceholder()

            alert.addButton("Launch VWO") { [unowned self] in
                self.launchVWO(APIkey.text!)
            }
            alert.showNotice("Launch VWO", subTitle: "", closeButtonTitle: "Cancel")
        }
    }
}
