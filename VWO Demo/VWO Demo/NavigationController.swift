//
//  NavigationController.swift
//  VWODemoApp
//
//  Created by Kaunteya Suryawanshi on 26/07/17.
//  Copyright © 2017 Wingify. All rights reserved.
//

import UIKit

protocol NavigationDelegate {
    func navigationActionMenuClicked()
    func navigationActionReloadClicked()
}

class NavigationController: UIViewController {

    var delegate: NavigationDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var controlLabel: UILabel!
    @IBOutlet weak var variationLabel: UILabel!

    @IBAction func actionReloadClicked(_ sender: Any) {
        self.delegate?.navigationActionReloadClicked()
    }

    @IBAction func actionMenuClicked(_ sender: Any) {
        self.delegate?.navigationActionMenuClicked()
    }
}
