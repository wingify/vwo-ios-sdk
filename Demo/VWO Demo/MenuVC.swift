//
//  MenuVC.swift
//  VWODemoApp
//
//  Created by Kaunteya Suryawanshi on 25/07/17.
//  Copyright © 2017 Wingify. All rights reserved.
//

import UIKit
import VWO
//import FLEX

enum HamburgerMenuItem: String {
    case sortingCampaign = "Sorting Campaign"
    case variableCampaign = "Variable Campaign"
    case apiKey = "Enter API Key"
    case about = "About"
    static var all: [HamburgerMenuItem] {
        return [.sortingCampaign, .variableCampaign, .apiKey, .about]
    }
}

protocol HamburgerMenuDelegate: class {
    func selectedMenuItem(item: HamburgerMenuItem)
}

class MenuVC : UIViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: HamburgerMenuDelegate?

    @IBAction func actionCloseMenu(_ sender: Any) {
        self.slideMenuController()?.closeLeft()
    }
}

//MARK: - UITableViewDataSource
extension MenuVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HamburgerMenuItem.all.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell")!
        cell.textLabel?.text = HamburgerMenuItem.all[indexPath.row].rawValue
        return cell
    }
}

//MARK: - UITableViewDelegate
extension MenuVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.slideMenuController()?.closeLeft()
        delegate?.selectedMenuItem(item: HamburgerMenuItem.all[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}
