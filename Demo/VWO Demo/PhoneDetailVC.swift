//
//  DetailsVC.swift
//  VWODemoApp
//
//  Created by Kaunteya Suryawanshi on 28/07/17.
//  Copyright © 2017 Wingify. All rights reserved.
//

import UIKit

class PhoneDetailVC: UIViewController {

    @IBOutlet weak var phoneImageHandle: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    var phone: Phone!
    
    @IBAction func actionClose(_ sender: Any) {
        self.view.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        updateViewForPhone()
    }

    private func updateViewForPhone() {
        nameLabel.text = phone.name
        phoneImageHandle.image = phone.image
        priceLabel.text = "$\(phone.price)"
    }
}
