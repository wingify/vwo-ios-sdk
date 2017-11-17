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
    
    func testDate() {
        let format = DateFormatter(); format.dateFormat = "dd-MM-yyyy"
        XCTAssertEqual((format.date(from: "01-01-2017")! as NSDate).dayOfWeek, 0) // Sunday
        XCTAssertEqual((format.date(from: "06-02-2017")! as NSDate).dayOfWeek, 1) // Monday
        XCTAssertEqual((format.date(from: "14-03-2017")! as NSDate).dayOfWeek, 2) // Tuesday
        XCTAssertEqual((format.date(from: "26-04-2017")! as NSDate).dayOfWeek, 3) // Wednesday
        XCTAssertEqual((format.date(from: "18-05-2017")! as NSDate).dayOfWeek, 4) // Thursday
        XCTAssertEqual((format.date(from: "23-06-2017")! as NSDate).dayOfWeek, 5) // Friday
        XCTAssertEqual((format.date(from: "29-07-2017")! as NSDate).dayOfWeek, 6) // Saturday
    }
}
