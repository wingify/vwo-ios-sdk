//
//  LoginVC.swift
//  VWODemoApp
//
//  Created by Kaunteya Suryawanshi on 25/07/17.
//  Copyright © 2017 Wingify. All rights reserved.
//

import UIKit
import VWO

class LoginVC: UIViewController {
    var hasSkip: Bool!, hasSocialMedia: Bool!

    var loginDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginDetail") as! LoginDetailVC

    @IBOutlet weak var mainStackViewField: UIStackView!
    @IBOutlet weak var socialMediaField: UIStackView!
    @IBOutlet weak var skipField: UIButton!

    class func makeView(hasSkip: Bool, hasSocialMedia: Bool) -> LoginVC {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as! LoginVC
        vc.hasSkip = hasSkip
        vc.hasSocialMedia = hasSocialMedia
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if hasSocialMedia == false {
            mainStackViewField.removeArrangedSubview(socialMediaField)
            socialMediaField.removeFromSuperview()
        }
        if hasSkip == false {
            mainStackViewField.removeArrangedSubview(skipField)
            skipField.removeFromSuperview()
        }
        self.view.addSubview(loginDetailVC.view)
        self.view.equalConstrains(subView: loginDetailVC.view)
    }

    override func viewWillAppear(_ animated: Bool) {
        loginDetailVC.view.isHidden = true
    }

    @IBAction func actionSkip(_ sender: Any) {
        VWO.trackConversion("landingPage")
        loginDetailVC.view.isHidden = false
        loginDetailVC.imageField.image = #imageLiteral(resourceName: "Skip")
        loginDetailVC.labelField.text = "Login Skipped"
    }

    @IBAction func actionLoginEmail(_ sender: Any) {
        VWO.trackConversion("landingPage")
        loginDetailVC.view.isHidden = false
        loginDetailVC.imageField.image = #imageLiteral(resourceName: "Check")
        loginDetailVC.labelField.text = "Login successful"
    }

    @IBAction func actionLoginFacebook(_ sender: Any) {
        VWO.trackConversion("landingPage")
        loginDetailVC.view.isHidden = false
        loginDetailVC.imageField.image = #imageLiteral(resourceName: "Check")
        loginDetailVC.labelField.text = "Facebook Login successful"
    }
}
