//
//  VisitorTypeTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 20/02/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest

class VisitorTypeTests: XCTestCase {
    func testNewEqual() {
        let json = JSONFrom(file: "VisitorTypeEqualNew")
        let evaluator = VWOSegmentEvaluator()
        evaluator.isReturning = false
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testNewNotEqual() {
        let json = JSONFrom(file: "VisitorTypeNotEqualNew")
        let evaluator = VWOSegmentEvaluator()
        evaluator.isReturning = false
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
        evaluator.isReturning = true
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testNewReturning() {
        let json = JSONFrom(file: "VisitorTypeEqualReturning")
        let evaluator = VWOSegmentEvaluator()
        evaluator.isReturning = true
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
        evaluator.isReturning = false
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testNewNotReturning() {
        let json = JSONFrom(file: "VisitorTypeNotEqualReturning")
        let evaluator = VWOSegmentEvaluator()
        evaluator.isReturning = false
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
        evaluator.isReturning = true
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }
}
