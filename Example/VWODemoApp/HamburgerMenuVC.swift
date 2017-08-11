//
//  HamburgerMenuVC.swift
//  VWODemoApp
//
//  Created by Kaunteya Suryawanshi on 25/07/17.
//  Copyright © 2017 Wingify. All rights reserved.
//

import UIKit

class HamburgerMenuVC: UIViewController {
    var mainViewController: UIViewController!
    var swiftViewController: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let swiftViewController = storyboard.instantiateViewController(withIdentifier: "SwiftViewController") as! SwiftViewController
//        self.swiftViewController = UINavigationController(rootViewController: swiftViewController)
    }
}
