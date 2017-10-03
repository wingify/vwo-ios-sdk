//
//  VWOTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 03/10/17.
//  Copyright © 2017 vwo. All rights reserved.
//

import XCTest
import UIKit

@testable import VWO

class VWOTestSwift: XCTestCase {

    override func setUp() { super.setUp() }

    override func tearDown() { super.tearDown() }
    
    func testiOSVersion() {
        let versionArray = UIDevice.current.systemVersion.split(separator: ".")
        let major = "\(versionArray[0])" //Converts String.Subsequence to String
        let minor = (versionArray.count >= 2) ? "\(versionArray[1])" : "0"
        let patch = (versionArray.count >= 3) ? "\(versionArray[2])" : "0"
        XCTAssertEqual(major, VWODevice.iOSVersionMinor(false, patch: false))
//        XCTAssertEqual(major, VWODevice.iOSVersionMinor(false, patch: true))//Must fail
        XCTAssertEqual("\(major).\(minor)", VWODevice.iOSVersionMinor(true, patch: false))
        XCTAssertEqual("\(major).\(minor).\(patch)", VWODevice.iOSVersionMinor(true, patch: true))
    }
}
