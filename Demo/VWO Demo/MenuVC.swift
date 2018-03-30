//
//  MenuVC.swift
//  VWODemoApp
//
//  Created by Kaunteya Suryawanshi on 25/07/17.
//  Copyright © 2017 Wingify. All rights reserved.
//

import UIKit
import VWO
import FLEX

class MenuVC : UIViewController {

    var optionList = ["Layout Campaign", "Onboarding Campaign", "Clear Data", "Enter API Key", "About", "Debug"];

    @IBOutlet weak var tableView: UITableView!

    func actionSelectionIndex(_ index: Int) {
        let containerVC = self.slideMenuController()?.mainViewController as! ContainerVC
        switch index {
        case 0: containerVC.activeView = .listGrid
        case 1: containerVC.activeView = .login
        case 2: campaignsClearShowAlert()
        case 3: changeAppKey()
        case 4: showAbout()
        case 5: FLEXManager.shared().showExplorer()
        default: fatalError()
        }
    }

    @IBAction func actionCloseMenu(_ sender: Any) {
        self.slideMenuController()?.closeLeft()
    }

    private func changeAppKey() {
        let message: String
        if let value = UserDefaults.standard.string(forKey: keyVWOApiKey) {
            message = "Current Key:\n \(value)"
        } else { message = "" }
        let alert = UIAlertController(title: "Add API Key", message: message, preferredStyle: .alert)
        var appKeyTextField: UITextField!

        alert.addTextField { (textField) in
            textField.placeholder = "VWO API Key"
            appKeyTextField = textField
            appKeyTextField.text = UIPasteboard.general.string
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            let apiKey = appKeyTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            guard self.isValid(apiKey: apiKey) else {
                self.showAlert("Invalid Key", button: "OK")
                return;
            }
            UserDefaults.standard.set(apiKey, forKey: keyVWOApiKey)
            self.clearVWOFiles()
            let container = self.slideMenuController()?.mainViewController as! ContainerVC
            container.activityIndicator.startAnimating()
            VWO.launch(apiKey: apiKey, userConfig: nil, completion: {
                DispatchQueue.main.async {
                    container.activityIndicator.stopAnimating()
                    self.showAlert("Success", message: "API Key changed successfully.\n Old campaigns cleared", button: "OK")
                }
            }, failure: nil)
        })
        self.present(alert, animated: true, completion: nil)
    }

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

    private func campaignsClearShowAlert() {
        let alert = UIAlertController(title: "Clear Data", message: "Do you want to clear campaigns data?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            self.clearVWOFiles()
            self.showAlert("Data cleared.", button: "OK")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func clearVWOFiles() {
        UserDefaults.standard.removeObject(forKey: "vwo.09cde70ba7a94aff9d843b1b846a79a7")

        if let path = Bundle.main.path(forResource: "VWOMessages", ofType: "plist") {
            try? FileManager.default.removeItem(atPath: path)
        }

        if let path = Bundle.main.path(forResource: "VWOCampaigns", ofType: "plist") {
            try? FileManager.default.removeItem(atPath: path)
        }
    }

    private func showAbout() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String

        let apiKey = UserDefaults.standard.string(forKey: keyVWOApiKey)
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")

        self.showAlert("Version: \(version)(\(build))", message: apiKey, button: "OK")
    }
}

//MARK: - UITableViewDataSource
extension MenuVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell")!
        cell.textLabel?.text = optionList[indexPath.row]
        return cell
    }
}

//MARK: - UITableViewDelegate
extension MenuVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.slideMenuController()?.closeLeft()
        actionSelectionIndex(indexPath.row)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}
