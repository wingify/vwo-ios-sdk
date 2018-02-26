//
//  VWOSegmentEvaluatorTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 16/11/17.
//  Copyright © 2017 vwo. All rights reserved.
//

import XCTest
import UIKit

class VWOSegmentEvaluatorTests: XCTestCase {

    let dateHourformat = DateFormatter(format: "dd-MM-yyyy HH:mm");
    let dateFormat = DateFormatter(format: "dd-MM-yyyy");

    override func setUp() { super.setUp()
        continueAfterFailure = false
    }

    func testInitializer() {
        let segment = VWOSegmentEvaluator(iOSVersion: "9.2", appVersion: "1.2", date: Date(), locale: NSLocale.current, isReturning: false, appDeviceType: .iPhone, customVariables: nil)
        XCTAssertNotNil(segment)
    }

    func testInvalidSegmentType() {
        // segment "type" is set to invalid number

        let evaluator = VWOSegmentEvaluator()
        let json = JSONFrom(file: "InvalidSegmentType")
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json))
    }
}

