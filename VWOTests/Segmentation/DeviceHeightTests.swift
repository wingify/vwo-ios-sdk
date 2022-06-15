//
//  DeviceHeightTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 09/03/18.
//  Copyright © 2018-2022 vwo. All rights reserved.
//

import XCTest

class DeviceHeightTests: XCTestCase {

    func testEqualTo() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "11", "operator": 11, "rOperandValue": "100" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.screenHeight = 100

        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.screenHeight = 101
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testNotEqualTo() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "11", "operator": 12, "rOperandValue": "100" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.screenHeight = 100
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.screenHeight = 101
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testGreaterThan() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "11", "operator": 15, "rOperandValue": "100" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.screenHeight = 100
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.screenHeight = 101
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.screenHeight = 99
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testLessThan() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "11", "operator": 16, "rOperandValue": "100" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.screenHeight = 100
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.screenHeight = 101
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.screenHeight = 99
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testROperatorDataTypeDouble() {
        //When ROperand is double precision should get stripped
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "11", "operator": 11, "rOperandValue": "100.1" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.screenHeight = 100
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testROperatorDataTypeString() {
        //When ROperand is string it should fall back to zero
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "11", "operator": 11, "rOperandValue": "INVALID" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.screenHeight = 0
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }
}
