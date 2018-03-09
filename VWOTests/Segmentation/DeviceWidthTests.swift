//
//  DeviceWidthHeightTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 09/03/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest

class DeviceWidthTests: XCTestCase {

    func testWidthEqualTo() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "10", "operator": 11, "rOperandValue": "100" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.screenWidth = 100
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.screenWidth = 101
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testWidthNotEqualTo() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "10", "operator": 12, "rOperandValue": "100" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.screenWidth = 100
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.screenWidth = 101
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testWidthGreaterThan() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "10", "operator": 15, "rOperandValue": "100" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.screenWidth = 100
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.screenWidth = 101
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.screenWidth = 99
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testWidthLessThan() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "10", "operator": 16, "rOperandValue": "100" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.screenWidth = 100
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.screenWidth = 101
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.screenWidth = 99
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testROperatorDataTypeDouble() {
        //When ROperand is double precision should get stripped
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "10", "operator": 11, "rOperandValue": "100.1" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.screenWidth = 100
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testROperatorDataTypeString() {
        //When ROperand is string it should fall back to zero
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "10", "operator": 11, "rOperandValue": "INVALID" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.screenWidth = 0
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

}
