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
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "1", "operator": 11, "rOperandValue": "10.3" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.iOSVersion = "10.3"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.iOSVersion = "11.3"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testiOSVersionNotEqualTo() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "1", "operator": 12, "rOperandValue": "11.1" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.iOSVersion = "11.3"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.iOSVersion = "11.1"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testiOSVersionGreaterThan() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "1", "operator": 15, "rOperandValue": "9.2" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.iOSVersion = "11"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.iOSVersion = "11.3"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.iOSVersion = "11.3.1"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.iOSVersion = "9.2"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.iOSVersion = "8.3"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testiOSVersionLessThan() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "1", "operator": 16, "rOperandValue": "10.3" ]]
        ]
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
