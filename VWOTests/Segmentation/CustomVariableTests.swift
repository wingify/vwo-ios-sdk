//
//  CustomVariableTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 26/02/18.
//  Copyright © 2018-2022 vwo. All rights reserved.
//

import XCTest

class CustomVariableTests: XCTestCase {
    func test1() {
        func testCustomVariable() {
            let json: [String : Any] = [
                "type": "custom",
                "partialSegments": [[ "type": "7",
                                      "operator": 5,
                                      "lOperandValue": "user",
                                      "rOperandValue": "paid" ]]
            ]

            let evaluator = VWOSegmentEvaluator()
            evaluator.customVariables = ["user" : "Paid"]
            XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: json))

            evaluator.customVariables = ["user" : "free"]
            XCTAssertFalse(evaluator.canUserBePartOfCampaign(forSegment: json))
        }

    }
}
