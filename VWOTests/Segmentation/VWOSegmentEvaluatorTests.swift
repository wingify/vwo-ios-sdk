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

    func fromJSON(file: String) -> [String: Any] {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: file, ofType: "json")!
        let url = URL(fileURLWithPath: path)
        let str = try! String(contentsOf: url, encoding: .utf8)
        return str.jsonToDictionary
    }

    override func setUp() { super.setUp() }

    override func tearDown() { super.tearDown() }

    func testiOSVersion() {
        XCTAssertEqual(VWODevice.deviceName, "x86_64")
    }

    func testPredefined() {
        let iPhoneJSON = fromJSON(file: "PredefinediPhone")
        let iPadJSON = fromJSON(file: "PredefinediPad")
        let returingJSON = fromJSON(file: "PredefinedReturningUser")
        let newUserJSON = fromJSON(file: "PredefinedNewUser")

        let segmentEvaluator1 = VWOSegmentEvaluator(iOSVersion: "11.0", appVersion: "1.2.3", date: Date(), isReturning: false, appDeviceType: .iPhone, customVariables: nil)
        XCTAssert(segmentEvaluator1.canUserBePartOfCampaign(forSegment: iPhoneJSON))
        XCTAssertFalse(segmentEvaluator1.canUserBePartOfCampaign(forSegment: iPadJSON))
        XCTAssertFalse(segmentEvaluator1.canUserBePartOfCampaign(forSegment: returingJSON))
        XCTAssert(segmentEvaluator1.canUserBePartOfCampaign(forSegment: newUserJSON))

        let segmentEvaluator2 = VWOSegmentEvaluator(iOSVersion: "11.0", appVersion: "1.2.3", date: Date(), isReturning: true, appDeviceType: .iPad, customVariables: nil)
        XCTAssertFalse(segmentEvaluator2.canUserBePartOfCampaign(forSegment: iPhoneJSON))
        XCTAssert(segmentEvaluator2.canUserBePartOfCampaign(forSegment: iPadJSON))
        XCTAssert(segmentEvaluator2.canUserBePartOfCampaign(forSegment: returingJSON))
        XCTAssertFalse(segmentEvaluator2.canUserBePartOfCampaign(forSegment: newUserJSON))
    }
}

