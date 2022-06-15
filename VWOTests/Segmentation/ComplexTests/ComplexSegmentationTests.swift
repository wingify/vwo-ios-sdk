//
//  ComplexSegmentationTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 26/02/18.
//  Copyright © 2018-2022 vwo. All rights reserved.
//

import XCTest

class ComplexSegmentationTests: XCTestCase {

    func testAnd1() {
        let json = JSONFrom(file: "And1")

        let evaluator = VWOSegmentEvaluator()
        evaluator.customVariables = ["user" : "Paid"]
        evaluator.iOSVersion = "10.2"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testAnd2() {
        let json = JSONFrom(file: "And2")
        let evaluator = VWOSegmentEvaluator()
        evaluator.customVariables = ["user" : "Paid"]
        evaluator.iOSVersion = "10.2"
        evaluator.appVersion = "1.2.1"
        evaluator.date = dateHourformat.date(from: "01-01-2017 16:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testOr1() {
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
        let json = JSONFrom(file: "Or2")
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.appVersion = "2.0"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testOr3() {
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        evaluator.iOSVersion = "8.2"
        evaluator.date = dateHourformat.date(from: "01-01-2017 16:23")!
        let json = JSONFrom(file: "Or3")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testComplex1() {
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "2.2"
        evaluator.iOSVersion = "8.2"
        let json = JSONFrom(file: "Complex1")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.iOSVersion = "9.2"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testComplex2() {
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "2.2"
        evaluator.iOSVersion = "8.2"
        evaluator.date = dateFormat.date(from: "20-11-2017")!
        let json = JSONFrom(file: "Complex2")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.appVersion = "1.2"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testBracket1() {
        //Only one segment which has left and right bracket
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        evaluator.iOSVersion = "8.2"
        evaluator.date = dateFormat.date(from: "20-11-2017")!
        let json = JSONFrom(file: "Bracket1")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testBracket2() {
        //Only one segment which has left and right bracket
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        evaluator.iOSVersion = "9.3"
        evaluator.date = dateFormat.date(from: "20-11-2017")!
        let json = JSONFrom(file: "Bracket2")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testBracket3() {
        //First segment has previous logical operator
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        evaluator.iOSVersion = "9.3"
        evaluator.date = dateFormat.date(from: "20-11-2017")!
        let json = JSONFrom(file: "Bracket3")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testBracket4() {
        //First segment has previous logical operator
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        evaluator.iOSVersion = "9.3"
        evaluator.date = dateFormat.date(from: "20-11-2017")!
        let json = JSONFrom(file: "Bracket4")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testNestedBracket2() {
        //First segment has previous logical operator
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        evaluator.iOSVersion = "9.3"
        evaluator.date = dateFormat.date(from: "20-11-2017")!
        let json = JSONFrom(file: "NestedBracket2")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }
}
