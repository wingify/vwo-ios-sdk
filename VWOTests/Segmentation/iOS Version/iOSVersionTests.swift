//
//  iOSVersionTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 22/02/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest

class iOSVersionTests: XCTestCase {

    func testiOSVersionEqualTo() {
        let json = JSONFrom(file: "iOSVersionEqualTo")
        let evaluator = VWOSegmentEvaluator()
        evaluator.iOSVersion = "10.3"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.iOSVersion = "11.3"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testiOSVersionNotEqualTo() {
        let json = JSONFrom(file: "iOSVersionNotEqualTo")
        let evaluator = VWOSegmentEvaluator()
        evaluator.iOSVersion = "11.3"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.iOSVersion = "10.3"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testiOSVersionGreaterThan() {
        let json = JSONFrom(file: "iOSVersionGreaterThan")
        let evaluator = VWOSegmentEvaluator()
        evaluator.iOSVersion = "11"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.iOSVersion = "11.3"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.iOSVersion = "11.3.1"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.iOSVersion = "10.3"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.iOSVersion = "9.3"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testiOSVersionLessThan() {
        let json = JSONFrom(file: "iOSVersionLessThan")
        let evaluator = VWOSegmentEvaluator()
        evaluator.iOSVersion = "9.3"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.iOSVersion = "10.2"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.iOSVersion = "10.1.1"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.iOSVersion = "11.1.1"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }
}
