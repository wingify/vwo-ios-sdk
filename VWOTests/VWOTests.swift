//
//  VWOTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 03/10/17.
//  Copyright © 2017-2022 vwo. All rights reserved.
//

import XCTest
import UIKit

class VWOTestSwift: XCTestCase {

    override func setUp() { super.setUp() }

    override func tearDown() { super.tearDown() }

    func testDayOfWeek() {
        let format = DateFormatter(); format.dateFormat = "dd-MM-yyyy"
        XCTAssertEqual((format.date(from: "01-01-2017")! as NSDate).dayOfWeek, 0) // Sunday
        XCTAssertEqual((format.date(from: "06-02-2017")! as NSDate).dayOfWeek, 1) // Monday
        XCTAssertEqual((format.date(from: "14-03-2017")! as NSDate).dayOfWeek, 2) // Tuesday
        XCTAssertEqual((format.date(from: "26-04-2017")! as NSDate).dayOfWeek, 3) // Wednesday
        XCTAssertEqual((format.date(from: "18-05-2017")! as NSDate).dayOfWeek, 4) // Thursday
        XCTAssertEqual((format.date(from: "23-06-2017")! as NSDate).dayOfWeek, 5) // Friday
        XCTAssertEqual((format.date(from: "29-07-2017")! as NSDate).dayOfWeek, 6) // Saturday
    }

    func testHourOfTheDay() {
        let format = DateFormatter(); format.dateFormat = "dd-MM-yyyy HH:mm"
        XCTAssertEqual((format.date(from: "01-01-2017 01:23")! as NSDate).hourOfTheDay, 1)
        XCTAssertEqual((format.date(from: "01-01-2017 02:03")! as NSDate).hourOfTheDay, 2)
        XCTAssertEqual((format.date(from: "01-01-2017 03:23")! as NSDate).hourOfTheDay, 3)
        XCTAssertEqual((format.date(from: "01-01-2017 04:23")! as NSDate).hourOfTheDay, 4)
        XCTAssertEqual((format.date(from: "01-01-2017 05:23")! as NSDate).hourOfTheDay, 5)
        XCTAssertEqual((format.date(from: "01-01-2017 06:23")! as NSDate).hourOfTheDay, 6)
        XCTAssertEqual((format.date(from: "01-01-2017 07:43")! as NSDate).hourOfTheDay, 7)
        XCTAssertEqual((format.date(from: "01-01-2017 08:23")! as NSDate).hourOfTheDay, 8)
        XCTAssertEqual((format.date(from: "01-01-2017 09:23")! as NSDate).hourOfTheDay, 9)
        XCTAssertEqual((format.date(from: "01-01-2017 10:23")! as NSDate).hourOfTheDay, 10)
        XCTAssertEqual((format.date(from: "01-01-2017 11:23")! as NSDate).hourOfTheDay, 11)
        XCTAssertEqual((format.date(from: "01-01-2017 12:23")! as NSDate).hourOfTheDay, 12)
        XCTAssertEqual((format.date(from: "01-01-2017 13:23")! as NSDate).hourOfTheDay, 13)
        XCTAssertEqual((format.date(from: "01-01-2017 14:23")! as NSDate).hourOfTheDay, 14)
        XCTAssertEqual((format.date(from: "01-01-2017 15:23")! as NSDate).hourOfTheDay, 15)
        XCTAssertEqual((format.date(from: "01-01-2017 16:23")! as NSDate).hourOfTheDay, 16)
        XCTAssertEqual((format.date(from: "01-01-2017 17:23")! as NSDate).hourOfTheDay, 17)
        XCTAssertEqual((format.date(from: "01-01-2017 18:23")! as NSDate).hourOfTheDay, 18)
        XCTAssertEqual((format.date(from: "01-01-2017 19:23")! as NSDate).hourOfTheDay, 19)
        XCTAssertEqual((format.date(from: "01-01-2017 20:23")! as NSDate).hourOfTheDay, 20)
        XCTAssertEqual((format.date(from: "01-01-2017 21:23")! as NSDate).hourOfTheDay, 21)
        XCTAssertEqual((format.date(from: "01-01-2017 22:23")! as NSDate).hourOfTheDay, 22)
        XCTAssertEqual((format.date(from: "01-01-2017 23:23")! as NSDate).hourOfTheDay, 23)
    }

    func testToXDotY() {
        XCTAssertEqual(("1.2.1" as NSString).version2Places, "1.2")
        XCTAssertEqual(("1.2" as NSString).version2Places, "1.2")
        XCTAssertEqual(("1.0" as NSString).version2Places, "1.0")
        XCTAssertEqual(("1" as NSString).version2Places, "1.0")
    }

    func testCompareInvalid() {
        XCTAssertEqual(("" as NSString).compareVersion("1"), .invalid)
        XCTAssertEqual(("1.2" as NSString).compareVersion(""), .invalid)
    }

    func testCompareStringVersionEqual() {
        XCTAssertEqual(("1.0" as NSString).compareVersion("1"), .equal)
        XCTAssertEqual(("1.0.0" as NSString).compareVersion("1"), .equal)
        XCTAssertEqual(("1.0.0" as NSString).compareVersion("1.0"), .equal)
        XCTAssertEqual(("1.0.0" as NSString).compareVersion("1.0.0"), .equal)
        XCTAssertEqual(("1.0" as NSString).compareVersion("1.0.0"), .equal)
        XCTAssertEqual(("1" as NSString).compareVersion("1.0.0"), .equal)
    }

    func testCompareVersionLessThan() {
        XCTAssertEqual(("1" as NSString).compareVersion("2"), .lesser)
        XCTAssertEqual(("1.0" as NSString).compareVersion("2"), .lesser)
        XCTAssertEqual(("1.1" as NSString).compareVersion("2"), .lesser)
        XCTAssertEqual(("1.0.1" as NSString).compareVersion("2"), .lesser)
        XCTAssertEqual(("9.0.1" as NSString).compareVersion("12"), .lesser)
        XCTAssertEqual(("9" as NSString).compareVersion("12.1"), .lesser)
    }

    func testCompareVersionGreater() {
        XCTAssertEqual(("14.1" as NSString).compareVersion("14"), .greater)
        XCTAssertEqual(("14" as NSString).compareVersion("2"), .greater)
        XCTAssertEqual(("14.0" as NSString).compareVersion("2"), .greater)
        XCTAssertEqual(("14" as NSString).compareVersion("2.1"), .greater)
        XCTAssertEqual(("14.0.1" as NSString).compareVersion("2.1"), .greater)
        XCTAssertEqual(("14.0.1" as NSString).compareVersion("2.1.0"), .greater)
        XCTAssertEqual(("14" as NSString).compareVersion("2.1.0"), .greater)
    }
}
