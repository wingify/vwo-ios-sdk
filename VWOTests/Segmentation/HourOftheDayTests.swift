//
//  HourOftheDayTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 22/02/18.
//  Copyright © 2018-2022 vwo. All rights reserved.
//

import XCTest

let dateHourformat = DateFormatter(format: "dd-MM-yyyy HH:mm");

class HourOftheDayTests: XCTestCase {

    func testHourOfTheDayEqualSingle() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "4", "operator": 11, "rOperandValue": [6]]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.date = dateHourformat.date(from: "01-01-2017 06:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testHourOfTheDayNotEqualSingle() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "4", "operator": 12, "rOperandValue": [6]]]
        ]
        let evaluator = VWOSegmentEvaluator()

        evaluator.date = dateHourformat.date(from: "01-01-2017 06:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = dateHourformat.date(from: "01-01-2017 16:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testHourOfTheDayMultiple() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "4", "operator": 11, "rOperandValue": [4, 6, 20]]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.date = dateHourformat.date(from: "01-01-2017 06:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = dateHourformat.date(from: "01-01-2017 04:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = dateHourformat.date(from: "01-01-2017 20:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = dateHourformat.date(from: "01-01-2017 11:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = dateHourformat.date(from: "01-01-2017 07:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testHourOfTheDayMultipleNotEqual() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "4", "operator": 12, "rOperandValue": [4, 6, 20]]]
        ]
        let evaluator = VWOSegmentEvaluator()

        evaluator.date = dateHourformat.date(from: "01-01-2017 04:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = dateHourformat.date(from: "01-01-2017 06:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = dateHourformat.date(from: "01-01-2017 20:23")!
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = dateHourformat.date(from: "01-01-2017 21:23")!
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)


    }
}
