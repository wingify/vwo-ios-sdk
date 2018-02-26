//
//  PredefinedSegmentTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 20/02/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest

class PredefinedSegmentTests: XCTestCase {

    func testPredefinediPhone() {
        let json: [String : Any] = [
            "type": "predefined",
            "segment_code": ["device" : "iPhone"]
        ]

        let evaluator = VWOSegmentEvaluator()
        evaluator.appleDeviceType = .iPhone
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testPredefinediPad() {
        let json: [String : Any] = [
            "type": "predefined",
            "segment_code": ["device" : "iPad"]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.appleDeviceType = .iPad
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testPredefinedReturningUser() {
        let json: [String : Any] = [
            "type": "predefined",
            "segment_code": ["returning_visitor" : true]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.isReturning = true
        evaluator.appleDeviceType = .iPhone

        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testPredefinedNewUser() {
        let json: [String : Any] = [
            "type": "predefined",
            "segment_code": ["returning_visitor" : false]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.isReturning = false
        evaluator.appleDeviceType = .iPhone

        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }
}
