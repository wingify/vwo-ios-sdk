//
//  APIKeyManager.swift
//  VWO Demo
//
//  Created by Kaunteya Suryawanshi on 24/07/18.
//  Copyright © 2018 Wingify. All rights reserved.
//

import UIKit
import SCLAlertView

/// Handles stuff that is to be done when user clicks on "Enter API Key"
struct APIKeyManager {
    static func showAlert() {

        let alert = SCLAlertView(
            appearance: SCLAlertView.SCLAppearance(
                kWindowWidth: UIScreen.main.bounds.width
            )
        )
        let APIkeytextField: UITextField = alert.addTextField("Enter API key")
        APIkeytextField.text = getAPIKeyForPlaceholder()

        alert.addButton("Launch VWO") {
            if _isValid(apiKey: APIkeytextField.text!) {
                VWOManager.launch(APIkeytextField.text!)
            } else {
                SCLAlertView().showError("API Key error", subTitle: "")
            }
        }
        alert.showNotice("Launch VWO", subTitle: "", closeButtonTitle: "Cancel")
    }

    /// Tries to find if there is a valid API key in clipboard or Xcode launch parameters
    static func getAPIKeyForPlaceholder() -> String? {
        // Fetch from clipboard
        if let clipboard = UIPasteboard.general.string,
            _isValid(apiKey: clipboard) {
            return clipboard
        }

        // Xcode launch parameters
        if let value = UserDefaults.standard.string(forKey: "VWOApiKey") {
            return value
        }
        return nil
    }

    ///Key must be in format `[32Chars]-[NUMS]`
    static private func _isValid(apiKey: String) -> Bool {
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

}
