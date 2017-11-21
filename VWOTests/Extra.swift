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

extension Dictionary where Key == String, Value == Any {
    var segmentDescription: String {
        let type = self["type"] as! String
        if type == "predefined" {
            return self["description"] as! String
        }
        let partialSegments:[[String : Any]] = self["partialSegments"] as! [[String : Any]]

        return partialSegments.map { segment in
            var str = ""
            if let previousLogialOperator = segment["prevLogicalOperator"] as? String {
                str += "       \(previousLogialOperator)\n"
            }
            let type = segment["type"] as! String
            if type == "7" {str += "CustomVariable"}
            if type == "6" {str += "AppVersion"}
            if type == "1" {str += "iOSVersion"}
            if type == "3" {str += "DayOfWeek"}
            if type == "4" {str += "HourOfTheDay"}

            if let leftOperand = segment["lOperandValue"] as? String {
                str += " \(leftOperand)"
            }
            let `operator` = segment["operator"] as! Int
            if `operator` == 1 {str += " IsEqualToCaseInsensitive"}
            if `operator` == 2 {str += " IsNotEqualToCaseInsensitive"}
            if `operator` == 3 {str += " IsEqualToCaseSensitive"}
            if `operator` == 4 {str += " IsNotEqualToCaseSensitive"}
            if `operator` == 5 {str += " MatchesRegexCaseInsensitive"}
            if `operator` == 6 {str += " MatchesRegexCaseSensitive"}
            if `operator` == 7 {str += " Contains"}
            if `operator` == 8 {str += " DoesNotContain"}
            if `operator` == 9 {str += " IsBlank"}
            if `operator` == 10 {str += " IsNotBlank"}
            if `operator` == 11 {str += " IsEqualTo"}
            if `operator` == 12 {str += " IsNotEqualTo"}
            if `operator` == 13 {str += " StartsWith"}
            if `operator` == 14 {str += " EndsWith"}
            if `operator` == 15 {str += " GreaterThan"}
            if `operator` == 16 {str += " LessThan"}
            if `operator` == 17 {str += " Converted"}
            if `operator` == 18 {str += " NotConverted"}

            if let rightOperand = segment["rOperandValue"] as? [Int] {
                str += " [" + rightOperand.map(String.init).joined(separator:", ") + "]"
            }
            if let rightOperand = segment["rOperandValue"] as? String {
                str += " \(rightOperand)"
            }
            return str
        }.joined(separator: "\n")
    }
}
