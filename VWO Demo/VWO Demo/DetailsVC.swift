//
//  DetailsVC.swift
//  VWODemoApp
//
//  Created by Kaunteya Suryawanshi on 28/07/17.
//  Copyright © 2017 Wingify. All rights reserved.
//

import UIKit

class DetailsVC: UIViewController {

    @IBOutlet weak var phoneImageHandle: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    @IBAction func actionClose(_ sender: Any) {
        self.view.isHidden = true
    }

    func setViewFor(phone: Phone) {
        nameLabel.text = phone.name
        phoneImageHandle.image = phone.image
        priceLabel.text = "$\(phone.price)"
    }
}
