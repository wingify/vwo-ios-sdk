//
//  LocationTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 09/03/18.
//  Copyright © 2018-2022 vwo. All rights reserved.
//

import XCTest
extension Locale {
    static func from(countryCode: String) -> Locale {
        let id = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue as String : countryCode])
        return Locale(identifier: id)
    }
}
class LocationTests: XCTestCase {

    func testEqual() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "5", "operator": 11, "rOperandValue": ["AL", "AI" ]]]
        ]

        let evaluator = VWOSegmentEvaluator()

        evaluator.locale = Locale.from(countryCode: "AL")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.locale = Locale.from(countryCode: "AI")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.locale = Locale.from(countryCode: "US")
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)
    }

    func testNotEqual() {
        let json: [String : Any] = [
            "type": "custom",
            "partialSegments": [[ "type": "5", "operator": 12, "rOperandValue": ["AU", "IN", "US"]]]
        ]

        let evaluator = VWOSegmentEvaluator()

        evaluator.locale = Locale.from(countryCode: "AR")
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.locale = Locale.from(countryCode: "AU")
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

        evaluator.locale = Locale.from(countryCode: "IN")
        XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json), json.segmentDescription)

    }
}
