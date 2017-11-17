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

    func fromJSON(file: String) -> [String: Any] {
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
        let json = fromJSON(file: "CustomVariable")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json))

        evaluator.customVariables = ["user" : "free"]
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json))
    }

    func testAppVersion() {
        let containsJSON = fromJSON(file: "AppVersionContains")
        let equalToJSON = fromJSON(file: "AppVersionEqualTo")
        let notEqualToJSON = fromJSON(file: "AppVersionNotEqualTo")
        let regexJSON = fromJSON(file: "AppVersionRegex")
        let startsWithJSON = fromJSON(file: "AppVersionStartsWith")

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
        let iOSVersionEqualTo10_3 = fromJSON(file: "iOSVersionEqualTo")
        let iOSVersionNotEqualTo10_3 = fromJSON(file: "iOSVersionNotEqualTo")
        let iOSVersionGreaterThan10_3 = fromJSON(file: "iOSVersionGreaterThan")
        let iOSVersionLessThan10_3 = fromJSON(file: "iOSVersionLessThan")

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
        let format = DateFormatter(); format.dateFormat = "dd-MM-yyyy"
        let sunday = format.date(from: "01-01-2017")!
        let monday = format.date(from: "06-02-2017")!
        let tuesday = format.date(from: "14-03-2017")!
        let wednesday = format.date(from: "26-04-2017")!
        let thursday = format.date(from: "18-05-2017")!
        let friday = format.date(from: "23-06-2017")!
        let saturday = format.date(from: "29-07-2017")!

        let dayOfWeekSunday = fromJSON(file: "DayOfWeekSingle")
        let dayOfWeekNotEqualMonday = fromJSON(file: "DayOfWeekSingleNotEqual")

        let evaluator = VWOSegmentEvaluator()
        evaluator.date = sunday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekSunday))
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekNotEqualMonday))


        let dayOfWeekSunWedFri = fromJSON(file: "DayOfWeekMultiple")
        evaluator.date = sunday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekSunWedFri))
        evaluator.date = monday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekSunWedFri))
        evaluator.date = tuesday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekSunWedFri))
        evaluator.date = wednesday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekSunWedFri))

        let dayOfWeekNotEqualMonWedThur = fromJSON(file: "DayOfWeekMultipleNotEqualTo")
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

    func testPredefined() {
        let iPhoneJSON = fromJSON(file: "PredefinediPhone")
        let iPadJSON = fromJSON(file: "PredefinediPad")
        let returingJSON = fromJSON(file: "PredefinedReturningUser")
        let newUserJSON = fromJSON(file: "PredefinedNewUser")

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
}

