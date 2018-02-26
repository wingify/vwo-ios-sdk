//
//  DayOfWeekTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 22/02/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest

let dateFormat = DateFormatter(format: "dd-MM-yyyy");
class DayOfWeekTests: XCTestCase {

    let sunday = dateFormat.date(from: "01-01-2017")! // 0
    let monday = dateFormat.date(from: "06-02-2017")! // 1
    let tuesday = dateFormat.date(from: "14-03-2017")! // 2
    let wednesday = dateFormat.date(from: "26-04-2017")!// 3
    let thursday = dateFormat.date(from: "18-05-2017")!// 4
    let friday = dateFormat.date(from: "23-06-2017")!// 5
    let saturday = dateFormat.date(from: "29-07-2017")!// 6

    func testDayOfWeekSingle() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "3", "operator": 11, "rOperandValue": [0]]]
        ]

        let evaluator = VWOSegmentEvaluator()
        evaluator.date = sunday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = wednesday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = friday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testDayOfWeekSingleNotEqual() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "3", "operator": 12, "rOperandValue": [1]]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.date = sunday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = wednesday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = monday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testDayOfWeekMultiple() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "3", "operator": 11, "rOperandValue": [0, 3, 5]]]
        ]
        let evaluator = VWOSegmentEvaluator()
        evaluator.date = sunday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = wednesday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = friday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = monday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = thursday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }

    func testDayOfWeekMultipleNotEqualTo() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "3", "operator": 12, "rOperandValue": [1, 3, 4]]]
        ]

        let evaluator = VWOSegmentEvaluator()
        evaluator.date = monday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = wednesday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = thursday
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.date = sunday
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }
}
