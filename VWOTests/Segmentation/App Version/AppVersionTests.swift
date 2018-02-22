//
//  AppVersionTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 20/02/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest

class AppVersionTests: XCTestCase {

    func testAppVersionContains() {
        let json = JSONFrom(file: "AppVersionContains")
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
        evaluator.appVersion = "1"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
        evaluator.appVersion = "2.1"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
        evaluator.appVersion = "2.0"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testAppVersionEqualTo() {
        let json = JSONFrom(file: "AppVersionEqualTo")
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
        evaluator.appVersion = "1"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testAppVersionNotEqualTo() {
        let json = JSONFrom(file: "AppVersionNotEqualTo")
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "3.1.2"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
        evaluator.appVersion = "1"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testAppVersionRegex() {
        let json = JSONFrom(file: "AppVersionRegex")
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
        evaluator.appVersion = "1"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
        evaluator.appVersion = "2.1"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testAppVersionStartsWith() {
        let json = JSONFrom(file: "AppVersionStartsWith")
        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "2.1.1"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
        evaluator.appVersion = "1.1"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testAppVersion() {
        let containsJSON = JSONFrom(file: "AppVersionContains")
        let equalToJSON = JSONFrom(file: "AppVersionEqualTo")
        let notEqualToJSON = JSONFrom(file: "AppVersionNotEqualTo")
        let regexJSON = JSONFrom(file: "AppVersionRegex")
        let startsWithJSON = JSONFrom(file: "AppVersionStartsWith")

        let evaluator = VWOSegmentEvaluator()
        evaluator.appVersion = "1.2"
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: containsJSON), containsJSON.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: equalToJSON), equalToJSON.segmentDescription)
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: notEqualToJSON), notEqualToJSON.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: regexJSON), regexJSON.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: startsWithJSON), startsWithJSON.segmentDescription)

        evaluator.appVersion = "1.0"
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: equalToJSON), equalToJSON.segmentDescription)
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: notEqualToJSON), notEqualToJSON.segmentDescription)
    }

}
