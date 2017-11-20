//
//  File.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 16/11/17.
//  Copyright © 2017 vwo. All rights reserved.
//

import Foundation

extension String {
    var jsonToDictionary: [String: Any] {
        let data = self.data(using: .utf8)!
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
    }
}

extension DateFormatter {
    convenience init(format: String) {
        self.init()
        self.dateFormat = format
    }
}
