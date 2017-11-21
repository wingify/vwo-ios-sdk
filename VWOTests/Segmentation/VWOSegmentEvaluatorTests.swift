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

    override func setUp() { super.setUp()
        continueAfterFailure = false
    }

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
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: containsJSON), containsJSON.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: equalToJSON), equalToJSON.segmentDescription)
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: notEqualToJSON), notEqualToJSON.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: regexJSON), regexJSON.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: startsWithJSON), startsWithJSON.segmentDescription)

        evaluator.appVersion = "1.0"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: equalToJSON), equalToJSON.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: notEqualToJSON), notEqualToJSON.segmentDescription)
    }

    func testiOSVersion() {
        let iOSVersionEqualTo10_3 = JSONFrom(file: "iOSVersionEqualTo")
        let iOSVersionNotEqualTo10_3 = JSONFrom(file: "iOSVersionNotEqualTo")
        let iOSVersionGreaterThan10_3 = JSONFrom(file: "iOSVersionGreaterThan")
        let iOSVersionLessThan10_3 = JSONFrom(file: "iOSVersionLessThan")

        let evaluator = VWOSegmentEvaluator()
        evaluator.iOSVersion = "10.3"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionEqualTo10_3), iOSVersionEqualTo10_3.segmentDescription)
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionNotEqualTo10_3), iOSVersionNotEqualTo10_3.segmentDescription)
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionGreaterThan10_3), iOSVersionGreaterThan10_3.segmentDescription)
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionLessThan10_3), iOSVersionLessThan10_3.segmentDescription)

        evaluator.iOSVersion = "11.0"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionEqualTo10_3), iOSVersionEqualTo10_3.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionNotEqualTo10_3), iOSVersionNotEqualTo10_3.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionGreaterThan10_3), iOSVersionGreaterThan10_3.segmentDescription)
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionLessThan10_3), iOSVersionLessThan10_3.segmentDescription)

        evaluator.iOSVersion = "8.2"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionEqualTo10_3), iOSVersionEqualTo10_3.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionNotEqualTo10_3), iOSVersionNotEqualTo10_3.segmentDescription)
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionGreaterThan10_3), iOSVersionGreaterThan10_3.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: iOSVersionLessThan10_3), iOSVersionLessThan10_3.segmentDescription)
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
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekSunday), dayOfWeekSunday.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekNotEqualMonday), dayOfWeekNotEqualMonday.segmentDescription)


        let dayOfWeekSunWedFri = JSONFrom(file: "DayOfWeekMultiple")
        evaluator.date = sunday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekSunWedFri), dayOfWeekSunWedFri.segmentDescription)
        evaluator.date = monday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekSunWedFri), dayOfWeekSunWedFri.segmentDescription)
        evaluator.date = tuesday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekSunWedFri), dayOfWeekSunWedFri.segmentDescription)
        evaluator.date = wednesday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekSunWedFri), dayOfWeekSunWedFri.segmentDescription)

        let dayOfWeekNotEqualMonWedThur = JSONFrom(file: "DayOfWeekMultipleNotEqualTo")
        evaluator.date = sunday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekNotEqualMonWedThur), dayOfWeekNotEqualMonWedThur.segmentDescription)
        evaluator.date = monday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekNotEqualMonWedThur), dayOfWeekNotEqualMonWedThur.segmentDescription)
        evaluator.date = wednesday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekNotEqualMonWedThur), dayOfWeekNotEqualMonWedThur.segmentDescription)
        evaluator.date = thursday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekNotEqualMonWedThur), dayOfWeekNotEqualMonWedThur.segmentDescription)
        evaluator.date = friday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekNotEqualMonWedThur), dayOfWeekNotEqualMonWedThur.segmentDescription)
        evaluator.date = saturday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: dayOfWeekNotEqualMonWedThur), dayOfWeekNotEqualMonWedThur.segmentDescription)
    }

    func testHourOfTheDay(){
        let evaluator = VWOSegmentEvaluator()

        let hourOfTheDay6 = JSONFrom(file: "HourOfTheDay")
        evaluator.date = dateHourformat.date(from: "01-01-2017 06:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDay6), hourOfTheDay6.segmentDescription)
        evaluator.date = dateHourformat.date(from: "01-02-2017 16:13")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDay6), hourOfTheDay6.segmentDescription)

        let hourOfTheDayNotEqual16 = JSONFrom(file: "HourOfTheDayNotEqual")
        evaluator.date = dateHourformat.date(from: "01-01-2017 16:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayNotEqual16), hourOfTheDayNotEqual16.segmentDescription)
        evaluator.date = dateHourformat.date(from: "01-01-2016 02:44")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayNotEqual16), hourOfTheDayNotEqual16.segmentDescription)


        let hourOfTheDayMultiple4_6_20 = JSONFrom(file: "HourOfTheDayMultiple")
        evaluator.date = dateHourformat.date(from: "01-01-2017 04:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultiple4_6_20), hourOfTheDayMultiple4_6_20.segmentDescription)
        evaluator.date = dateHourformat.date(from: "01-01-2017 06:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultiple4_6_20), hourOfTheDayMultiple4_6_20.segmentDescription)
        evaluator.date = dateHourformat.date(from: "01-01-2017 20:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultiple4_6_20), hourOfTheDayMultiple4_6_20.segmentDescription)
        evaluator.date = dateHourformat.date(from: "01-01-2017 07:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultiple4_6_20), hourOfTheDayMultiple4_6_20.segmentDescription)
        evaluator.date = dateHourformat.date(from: "01-01-2017 22:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultiple4_6_20), hourOfTheDayMultiple4_6_20.segmentDescription)

        let hourOfTheDayMultipleNotEqual2_14_16 = JSONFrom(file: "HourOfTheDayMultipleNotEqual")
        evaluator.date = dateHourformat.date(from: "01-01-2017 04:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultipleNotEqual2_14_16), hourOfTheDayMultipleNotEqual2_14_16.segmentDescription)
        evaluator.date = dateHourformat.date(from: "01-01-2017 06:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultipleNotEqual2_14_16), hourOfTheDayMultipleNotEqual2_14_16.segmentDescription)
        evaluator.date = dateHourformat.date(from: "01-01-2017 20:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultipleNotEqual2_14_16), hourOfTheDayMultipleNotEqual2_14_16.segmentDescription)
        evaluator.date = dateHourformat.date(from: "01-01-2017 02:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultipleNotEqual2_14_16), hourOfTheDayMultipleNotEqual2_14_16.segmentDescription)
        evaluator.date = dateHourformat.date(from: "01-01-2017 14:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultipleNotEqual2_14_16), hourOfTheDayMultipleNotEqual2_14_16.segmentDescription)
        evaluator.date = dateHourformat.date(from: "01-01-2017 16:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: hourOfTheDayMultipleNotEqual2_14_16), hourOfTheDayMultipleNotEqual2_14_16.segmentDescription)

    }

    func testPredefined() {
        let iPhoneJSON = JSONFrom(file: "PredefinediPhone")
        let iPadJSON = JSONFrom(file: "PredefinediPad")
        let returingJSON = JSONFrom(file: "PredefinedReturningUser")
        let newUserJSON = JSONFrom(file: "PredefinedNewUser")

        let evaluator = VWOSegmentEvaluator()
        evaluator.isReturning = false
        evaluator.appleDeviceType = .iPhone
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: iPhoneJSON), iPhoneJSON.segmentDescription)
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iPadJSON), iPadJSON.segmentDescription)
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: returingJSON), returingJSON.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: newUserJSON), newUserJSON.segmentDescription)

        evaluator.isReturning = true
        evaluator.appleDeviceType = .iPad
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: iPhoneJSON), iPhoneJSON.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: iPadJSON), iPadJSON.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: returingJSON), returingJSON.segmentDescription)
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: newUserJSON), newUserJSON.segmentDescription)
    }

    func testbasicAnd1() {
        let evaluator = VWOSegmentEvaluator()
        evaluator.customVariables = ["user" : "Paid"]
        evaluator.iOSVersion = "10.2"

        let and1JSON = JSONFrom(file: "And1")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: and1JSON), and1JSON.segmentDescription)

        let and2JSON = JSONFrom(file: "And2")
        evaluator.appVersion = "1.2.1"
        evaluator.date = dateHourformat.date(from: "01-01-2017 16:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: and2JSON), and2JSON.segmentDescription)
    }
    func testOr() {
        let evaluator = VWOSegmentEvaluator()
        evaluator.customVariables = ["user" : "Paid"]
        evaluator.iOSVersion = "8.2"
        let or1JSON = JSONFrom(file: "Or1")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: or1JSON), or1JSON.segmentDescription)

        evaluator.customVariables = ["user" : "free"]
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: or1JSON), or1JSON.segmentDescription)
    }
    func testOr2() {
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        let or2JSON = JSONFrom(file: "Or2")
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: or2JSON))

        evaluator.appVersion = "2.0"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: or2JSON))
    }

    func testOr3() {
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        evaluator.iOSVersion = "8.2"
        evaluator.date = dateHourformat.date(from: "01-01-2017 16:23")!
        let or3JSON = JSONFrom(file: "Or3")
        Swift.print(or3JSON.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: or3JSON))
    }

    func testComplex1() {
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "2.2"
        evaluator.iOSVersion = "8.2"
        let complex1JSON3JSON = JSONFrom(file: "Complex1")
        Swift.print(complex1JSON3JSON.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: complex1JSON3JSON))

        evaluator.iOSVersion = "9.2"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: complex1JSON3JSON))
    }

    func testComplex2() {
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "2.2"
        evaluator.iOSVersion = "8.2"
        evaluator.date = dateFormat.date(from: "20-11-2017")!
        let complex2JSON3JSON = JSONFrom(file: "Complex2")
        Swift.print(complex2JSON3JSON.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: complex2JSON3JSON))

        evaluator.appVersion = "1.2"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: complex2JSON3JSON))
    }
}

