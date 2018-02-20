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
        let evaluator = VWOSegmentEvaluator()
        evaluator.appleDeviceType = .iPhone
        let json = JSONFrom(file: "PredefinediPhone")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testPredefinediPad() {
        let evaluator = VWOSegmentEvaluator()
        evaluator.appleDeviceType = .iPad
        let json = JSONFrom(file: "PredefinediPad")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testPredefinedReturningUser() {
        let json = JSONFrom(file: "PredefinedReturningUser")
        let evaluator = VWOSegmentEvaluator()
        evaluator.isReturning = true
        evaluator.appleDeviceType = .iPhone

        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testPredefinedNewUser() {
        let json = JSONFrom(file: "PredefinedNewUser")
        let evaluator = VWOSegmentEvaluator()
        evaluator.isReturning = false
        evaluator.appleDeviceType = .iPhone

        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }
}
