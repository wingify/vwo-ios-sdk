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
        let json = JSONFrom(file: "DeviceTypeIPhoneEqual")
        let evaluator = VWOSegmentEvaluator()
        evaluator.appleDeviceType = .iPhone
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testiPhoneNotEqual() {
        let json = JSONFrom(file: "DeviceTypeIPhoneNotEqual")
        let evaluator = VWOSegmentEvaluator()
        evaluator.appleDeviceType = .iPhone
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.appleDeviceType = .iPad
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testiPadEqual() {
        let json = JSONFrom(file: "DeviceTypeIPadEqual")
        let evaluator = VWOSegmentEvaluator()
        evaluator.appleDeviceType = .iPad
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testiPadNotEqual() {
        let json = JSONFrom(file: "DeviceTypeIPadNotEqual")
        let evaluator = VWOSegmentEvaluator()
        evaluator.appleDeviceType = .iPad
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.appleDeviceType = .iPhone
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

}
