//
//  ContainerVC.swift
//  VWODemoApp
//
//  Created by Kaunteya Suryawanshi on 26/07/17.
//  Copyright © 2017 Wingify. All rights reserved.
//

import UIKit
import VWO

enum Side { case left, right }
enum ActiveView { case listGrid, login }

class ContainerVC: UIViewController {

    var leftVC : UIViewController!
    var rightVC : UIViewController!
    var navController: NavigationController!

    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var activeView: ActiveView! {
        didSet {
            switch activeView! {
            case .listGrid: showListGridView()
            case .login: showLoginView()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activeView = ActiveView.listGrid
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "navbar" {
            navController = segue.destination as! NavigationController
            navController.delegate = self
        }
    }

    func addVC(side: Side, vc: UIViewController) {
        switch side {
        case .left:
            leftVC = vc
            leftView.subviews.forEach { $0.removeFromSuperview() }
            leftView.addSubview(leftVC.view)
            leftView.equalConstrains(subView: leftVC.view)
        case .right:
            rightVC = vc
            rightView.subviews.forEach { $0.removeFromSuperview() }
            rightView.addSubview(rightVC.view)
            rightView.equalConstrains(subView: rightVC.view)
        }
    }

    func showLoginView() {
        navController.titleLabel.text = "Onboarding Campaign"

        // Left
        navController.controlLabel.text = "(Email)"
        let leftLoginVC = LoginVC.makeView(hasSkip: false, hasSocialMedia: false)
        addVC(side: .left, vc: leftLoginVC)

        // Right
        let hasSkip: Bool = VWO.variationFor(key: "skip", defaultValue: false) as! Bool
        let hasSocialMedia: Bool = VWO.variationFor(key: "socialMedia", defaultValue: false) as! Bool
        navController.variationLabel.text = " (Email \(hasSkip ? ", Skip" : "")\(hasSocialMedia ? ", Social Media" : ""))"
        let rightLoginVC = LoginVC.makeView(hasSkip: hasSkip, hasSocialMedia: hasSocialMedia)
        addVC(side: .right, vc: rightLoginVC)
    }

    func showListGridView() {
        navController.titleLabel.text = "Layout Campaign"

        // Left
        navController.controlLabel.text = "(\(ListType.list.navDecription))"
        addVC(side: .left, vc: ListGridVC.makeViewFor(type: .list))

        // Right
        let variation = VWO.variationFor(key: "layout", defaultValue: "list") as! String
        let variationListType = ListType(rawValue: variation) ?? .list
        navController.variationLabel.text = "(\(variationListType.navDecription))"
        addVC(side: .right, vc: ListGridVC.makeViewFor(type: variationListType))
    }
}

//MARK: - NavigationDelegate
extension ContainerVC: NavigationDelegate {
    func navigationActionMenuClicked() {
        self.slideMenuController()?.openLeft()
    }
    func navigationActionReloadClicked() {
        let temp = activeView; activeView = temp
    }
}
