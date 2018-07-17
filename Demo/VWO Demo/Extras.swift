//
//  Extras.swift
//  VWODemoApp
//
//  Created by Kaunteya Suryawanshi on 28/07/17.
//  Copyright © 2017 Wingify. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(_ title: String, message: String? = nil, button: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIView {
    func equalConstrains(subView: UIView) {
        subView.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: subView.topAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: subView.rightAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: subView.bottomAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: subView.leftAnchor).isActive = true
    }
}

extension UIStoryboard {
    static var main: UIStoryboard {
        return  UIStoryboard(name: "Main", bundle: nil)
    }
    
    func instantiate<T>(identifier: String) -> T {
        return UIStoryboard.main.instantiateViewController(withIdentifier: identifier) as! T
    }
}
