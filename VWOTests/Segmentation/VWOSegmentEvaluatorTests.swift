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

    override func setUp() { super.setUp()
        continueAfterFailure = false
    }

    func testInitializer() {
        let segment = VWOSegmentEvaluator(iOSVersion: "9.2", appVersion: "1.2", date: Date(), locale: NSLocale.current, isReturning: false, appDeviceType: .iPhone, customVariables: nil)
        XCTAssertNotNil(segment)
    }

    func testInvalidSegmentType() {
        // segment "type" is set to invalid number

        let evaluator = VWOSegmentEvaluator()
        let json = JSONFrom(file: "InvalidSegmentType")
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json))
    }

    func testCustomVariable() {
        let evaluator = VWOSegmentEvaluator()
        evaluator.customVariables = ["user" : "Paid"]
        let json = JSONFrom(file: "CustomVariable")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json))

        evaluator.customVariables = ["user" : "free"]
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json))
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
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: or3JSON))
    }

    func testComplex1() {
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "2.2"
        evaluator.iOSVersion = "8.2"
        let complex1JSON3JSON = JSONFrom(file: "Complex1")
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
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: complex2JSON3JSON))

        evaluator.appVersion = "1.2"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: complex2JSON3JSON))
    }
    func testBracket1() {
        //Only one segment which has left and right bracket
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        evaluator.iOSVersion = "8.2"
        evaluator.date = dateFormat.date(from: "20-11-2017")!
        let bracket1JSON = JSONFrom(file: "Bracket1")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: bracket1JSON))
    }
    func testBracket2() {
        //Only one segment which has left and right bracket
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        evaluator.iOSVersion = "9.3"
        evaluator.date = dateFormat.date(from: "20-11-2017")!
        let bracketJSON = JSONFrom(file: "Bracket2")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: bracketJSON))
    }
    func testBracket3() {
        //First segment has previous logical operator
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        evaluator.iOSVersion = "9.3"
        evaluator.date = dateFormat.date(from: "20-11-2017")!
        let bracketJSON = JSONFrom(file: "Bracket3")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: bracketJSON))
    }
    func testBracket4() {
        //First segment has previous logical operator
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        evaluator.iOSVersion = "9.3"
        evaluator.date = dateFormat.date(from: "20-11-2017")!
        let bracketJSON = JSONFrom(file: "Bracket4")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: bracketJSON))
    }
    func testNestedBracket2() {
        //First segment has previous logical operator
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        evaluator.iOSVersion = "9.3"
        evaluator.date = dateFormat.date(from: "20-11-2017")!
        let bracketJSON = JSONFrom(file: "NestedBracket2")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: bracketJSON))
    }
}

