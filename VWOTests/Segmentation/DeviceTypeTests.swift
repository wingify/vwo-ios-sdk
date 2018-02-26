//
//  DeviceTypeTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 20/02/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest

class DeviceTypeTests: XCTestCase {

    func testiPhoneEqual() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "9", "operator": 11, "rOperandValue": "iPhone" ]]
        ]

        let evaluator = VWOSegmentEvaluator()
        evaluator.appleDeviceType = .iPhone
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testiPhoneNotEqual() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "9", "operator": 12, "rOperandValue": "iPhone" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.appleDeviceType = .iPhone
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.appleDeviceType = .iPad
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testiPadEqual() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "9", "operator": 11, "rOperandValue": "iPad" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.appleDeviceType = .iPad
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testiPadNotEqual() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "9", "operator": 12, "rOperandValue": "iPad" ]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.appleDeviceType = .iPad
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.appleDeviceType = .iPhone
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

}
