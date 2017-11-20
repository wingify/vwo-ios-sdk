//
//  VWOSegmentEvaluatorTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 16/11/17.
//  Copyright © 2017 vwo. All rights reserved.
//

import XCTest
import UIKit

class VWOSegmentEvaluatorTests: XCTestCase {

    let dateHourformat = DateFormatter(format: "dd-MM-yyyy HH:mm");
    let dateFormat = DateFormatter(format: "dd-MM-yyyy");

    func JSONFrom(file: String) -> [String: Any] {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: file, ofType: "json")!
        let url = URL(fileURLWithPath: path)
        let str = try! String(contentsOf: url, encoding: .utf8)
        return str.jsonToDictionary
    }

    override func setUp() { super.setUp() }

    override func tearDown() { super.tearDown() }

    func testCustomVariable() {
        let evaluator = VWOSegmentEvaluator()
        evaluator.customVariables = ["user" : "Paid"]
        let json = JSONFrom(file: "CustomVariable")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json))

        evaluator.customVariables = ["user" : "free"]
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json))
    }

    func testAppVersion() {
        let containsJSON = JSONFrom(file: "AppVersionContains")
        let equalToJSON = JSONFrom(file: "AppVersionEqualTo")
        let notEqualToJSON = JSONFrom(file: "AppVersionNotEqualTo")
        let regexJSON = JSONFrom(file: "AppVersionRegex")
        let startsWithJSON = JSONFrom(file: "AppVersionStartsWith")

        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: containsJSON))
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: equalToJSON))
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: notEqualToJSON))
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: regexJSON))
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: startsWithJSON))

        evaluator.appVersion = "1.0"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: equalToJSON))
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: notEqualToJSON))
    }

    func testiOSVersion() {
        let iOSVersionEqualTo10_3 = JSONFrom(file: "iOSVersionEqualTo")
        let iOSVersionNotEqualTo10_3 = JSONFrom(file: "iOSVersionNotEqualTo")
        let iOSVersionGreaterThan10_3 = JSONFrom(file: "iOSVersionGreaterThan")
        let iOSVersionLessThan10_3 = JSONFrom(file: "iOSVersionLessThan")

        let evaluator = VWOSegmentEvaluator()
        evaluator.iOSVersion = "10.3"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionEqualTo10_3))
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionNotEqualTo10_3))
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionGreaterThan10_3))
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionLessThan10_3))

        evaluator.iOSVersion = "11.0"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionEqualTo10_3))
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionNotEqualTo10_3))
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionGreaterThan10_3))
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionLessThan10_3))

        evaluator.iOSVersion = "8.2"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionEqualTo10_3))
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionNotEqualTo10_3))
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionGreaterThan10_3))
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionLessThan10_3))
    }

    func testDayOfWeek(){
        let sunday = dateFormat.date(from: "01-01-2017")!
        let monday = dateFormat.date(from: "06-02-2017")!
        let tuesday = dateFormat.date(from: "14-03-2017")!
        let wednesday = dateFormat.date(from: "26-04-2017")!
        let thursday = dateFormat.date(from: "18-05-2017")!
        let friday = dateFormat.date(from: "23-06-2017")!
        let saturday = dateFormat.date(from: "29-07-2017")!

        let dayOfWeekSunday = JSONFrom(file: "DayOfWeekSingle")
        let dayOfWeekNotEqualMonday = JSONFrom(file: "DayOfWeekSingleNotEqual")

        let evaluator = VWOSegmentEvaluator()
        evaluator.date = sunday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekSunday))
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekNotEqualMonday))


        let dayOfWeekSunWedFri = JSONFrom(file: "DayOfWeekMultiple")
        evaluator.date = sunday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekSunWedFri))
        evaluator.date = monday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekSunWedFri))
        evaluator.date = tuesday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekSunWedFri))
        evaluator.date = wednesday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekSunWedFri))

        let dayOfWeekNotEqualMonWedThur = JSONFrom(file: "DayOfWeekMultipleNotEqualTo")
        evaluator.date = sunday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekNotEqualMonWedThur))
        evaluator.date = monday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekNotEqualMonWedThur))
        evaluator.date = wednesday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekNotEqualMonWedThur))
        evaluator.date = thursday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekNotEqualMonWedThur))
        evaluator.date = friday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekNotEqualMonWedThur))
        evaluator.date = saturday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekNotEqualMonWedThur))
    }

    func testHourOfTheDay(){
        let evaluator = VWOSegmentEvaluator()

        let hourOfTheDay6 = JSONFrom(file: "HourOfTheDay")
        evaluator.date = dateHourformat.date(from: "01-01-2017 06:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDay6))
        evaluator.date = dateHourformat.date(from: "01-02-2017 16:13")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDay6))

        let hourOfTheDayNotEqual16 = JSONFrom(file: "HourOfTheDayNotEqual")
        evaluator.date = dateHourformat.date(from: "01-01-2017 16:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayNotEqual16))
        evaluator.date = dateHourformat.date(from: "01-01-2016 02:44")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayNotEqual16))


        let hourOfTheDayMultiple4_6_20 = JSONFrom(file: "HourOfTheDayMultiple")
        evaluator.date = dateHourformat.date(from: "01-01-2017 04:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultiple4_6_20))
        evaluator.date = dateHourformat.date(from: "01-01-2017 06:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultiple4_6_20))
        evaluator.date = dateHourformat.date(from: "01-01-2017 20:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultiple4_6_20))
        evaluator.date = dateHourformat.date(from: "01-01-2017 07:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultiple4_6_20))
        evaluator.date = dateHourformat.date(from: "01-01-2017 22:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultiple4_6_20))

        let hourOfTheDayMultipleNotEqual2_14_16 = JSONFrom(file: "HourOfTheDayMultipleNotEqual")
        evaluator.date = dateHourformat.date(from: "01-01-2017 04:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultipleNotEqual2_14_16))
        evaluator.date = dateHourformat.date(from: "01-01-2017 06:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultipleNotEqual2_14_16))
        evaluator.date = dateHourformat.date(from: "01-01-2017 20:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultipleNotEqual2_14_16))
        evaluator.date = dateHourformat.date(from: "01-01-2017 02:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultipleNotEqual2_14_16))
        evaluator.date = dateHourformat.date(from: "01-01-2017 14:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultipleNotEqual2_14_16))
        evaluator.date = dateHourformat.date(from: "01-01-2017 16:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultipleNotEqual2_14_16))

    }

    func testPredefined() {
        let iPhoneJSON = JSONFrom(file: "PredefinediPhone")
        let iPadJSON = JSONFrom(file: "PredefinediPad")
        let returingJSON = JSONFrom(file: "PredefinedReturningUser")
        let newUserJSON = JSONFrom(file: "PredefinedNewUser")

        let evaluator = VWOSegmentEvaluator()
        evaluator.isReturning = false
        evaluator.appleDeviceType = .iPhone
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: iPhoneJSON))
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iPadJSON))
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: returingJSON))
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: newUserJSON))

        evaluator.isReturning = true
        evaluator.appleDeviceType = .iPad
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iPhoneJSON))
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: iPadJSON))
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: returingJSON))
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: newUserJSON))
    }

    func testbasicAnd1() {
        let evaluator = VWOSegmentEvaluator()
        evaluator.customVariables = ["user" : "Paid"]
        evaluator.iOSVersion = "10.2"

        let and1JSON = JSONFrom(file: "And1")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: and1JSON))

        let and2JSON = JSONFrom(file: "And2")
        evaluator.appVersion = "1.2.1"
        evaluator.date = dateHourformat.date(from: "01-01-2017 16:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: and2JSON))
    }
}

