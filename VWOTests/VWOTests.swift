//
//  VWOTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 03/10/17.
//  Copyright © 2017 vwo. All rights reserved.
//

import XCTest
import UIKit

class VWOTestSwift: XCTestCase {

    override func setUp() { super.setUp() }

    override func tearDown() { super.tearDown() }
    
    func testiOSVersion() {
        XCTAssertEqual(VWODevice.deviceName, "x86_64")
        
//        XCTAssertEqual(VWODevice.appleDeviceType, VWOAppleDeviceTypeiPhone)
    }
}
