//
//  LoginVC.swift
//  VWODemoApp
//
//  Created by Kaunteya Suryawanshi on 25/07/17.
//  Copyright © 2017 Wingify. All rights reserved.
//

import UIKit
import VWO

enum LoginType: String {
    case email, socialMedia, skip
    var navDecription: String {
        switch self {
        case .email: return "Email"
        case .socialMedia: return "Social Media"
        case .skip: return "Skip"
        }
    }
}

class LoginVC: UIViewController {
    var loginType: LoginType!
    var loginDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginDetail") as! LoginDetailVC

    @IBOutlet weak var mainStackViewField: UIStackView!
    @IBOutlet weak var socialMediaField: UIStackView!
    @IBOutlet weak var skipField: UIButton!

    class func makeViewFor(type: LoginType) -> LoginVC {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as! LoginVC
        vc.loginType = type
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        switch loginType! {
        case .email:
            mainStackViewField.removeArrangedSubview(socialMediaField)
            socialMediaField.removeFromSuperview()
            mainStackViewField.removeArrangedSubview(skipField)
            skipField.removeFromSuperview()
        case .socialMedia:
            mainStackViewField.removeArrangedSubview(skipField)
            skipField.removeFromSuperview()
        case .skip:
            mainStackViewField.removeArrangedSubview(socialMediaField)
            socialMediaField.removeFromSuperview()
        }
        self.view.addSubview(loginDetailVC.view)
        self.view.equalConstrains(subView: loginDetailVC.view)
    }

    override func viewWillAppear(_ animated: Bool) {
        loginDetailVC.view.isHidden = true
    }

    @IBAction func actionSkip(_ sender: Any) {
        VWO.markConversionFor(goal: "landingPage")
        loginDetailVC.view.isHidden = false
        loginDetailVC.imageField.image = #imageLiteral(resourceName: "Skip")
        loginDetailVC.labelField.text = "Login Skipped"
    }

    @IBAction func actionLoginEmail(_ sender: Any) {
        VWO.markConversionFor(goal: "landingPage")
        loginDetailVC.view.isHidden = false
        loginDetailVC.imageField.image = #imageLiteral(resourceName: "Check")
        loginDetailVC.labelField.text = "Login successful"
    }

    @IBAction func actionLoginFacebook(_ sender: Any) {
        VWO.markConversionFor(goal: "landingPage")
        loginDetailVC.view.isHidden = false
        loginDetailVC.imageField.image = #imageLiteral(resourceName: "Check")
        loginDetailVC.labelField.text = "Facebook Login successful"
    }
}
