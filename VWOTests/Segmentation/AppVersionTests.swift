//
//  AppVersionTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 20/02/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest

class AppVersionTests: XCTestCase {
    func    VersionEqualTo() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "6", "operator": 11, "rOperandValue": "1.0" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.appVersion = "1.0"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.appVersion = "1.0.0"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testAppVersionNotEqualTo() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "6", "operator": 12, "rOperandValue": "11.2" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "11.2"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.appVersion = "11.2.0"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.appVersion = "11.2.1"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testAppVersionGreaterThan() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "6", "operator": 15, "rOperandValue": "9.2" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "11"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.appVersion = "11.98"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.appVersion = "11.98.900"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.appVersion = "1.98.900"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testAppVersionLessThan() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "6", "operator": 16, "rOperandValue": "10.3.45" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "9.3"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }
}

