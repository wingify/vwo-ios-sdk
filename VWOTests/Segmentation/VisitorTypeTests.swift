//
//  VisitorTypeTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 20/02/18.
//  Copyright © 2018-2022 vwo. All rights reserved.
//

import XCTest

class VisitorTypeTests: XCTestCase {
    func testNewEqual() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "8", "operator": 11, "rOperandValue": "new" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.isReturning = false
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testNewNotEqual() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "8", "operator": 12, "rOperandValue": "new" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.isReturning = false
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
        evaluator.isReturning = true
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testNewReturning() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "8", "operator": 11, "rOperandValue": "ret" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.isReturning = true
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
        evaluator.isReturning = false
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testNewNotReturning() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "8", "operator": 12, "rOperandValue": "ret" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.isReturning = false
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
        evaluator.isReturning = true
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }
}
