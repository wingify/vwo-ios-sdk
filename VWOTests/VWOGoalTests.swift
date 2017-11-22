//
//  VWOGoalTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 22/11/17.
//  Copyright © 2017 vwo. All rights reserved.
//

import XCTest
class VWOGOalTests: XCTestCase {

    func testCustomGoalInitialiser() {
        let revenueGoalJSON = """
        {
            "type": "CUSTOM_GOAL",
            "identifier": "newGoal",
            "id": 12
        }
        """.jsonToDictionary
        let goal = VWOGoal(dictionary: revenueGoalJSON)
        XCTAssertNotNil(goal)
        XCTAssertEqual(goal!.type, .custom)
        XCTAssertNotNil(goal!.identifier)
        XCTAssertEqual(goal!.identifier, "newGoal")
        XCTAssertEqual(goal!.iD, 12)
    }

    func testRevenueInitialiser() {
        let revenueGoalJSON = """
        {
            "type": "REVENUE_TRACKING",
            "identifier": "goal45",
            "id": 1
        }
        """.jsonToDictionary
        let goal = VWOGoal(dictionary: revenueGoalJSON)
        XCTAssertNotNil(goal)
        XCTAssertEqual(goal!.type, .revenue)
        XCTAssertNotNil(goal!.identifier)
        XCTAssertEqual(goal!.identifier, "goal45")
        XCTAssertEqual(goal!.iD, 1)
    }

    func testMissingKeyId() {
        let idMissingGoalJSON = """
        {
            "type": "REVENUE_TRACKING",
            "identifier": "goal45"
        }
        """.jsonToDictionary
        let goal = VWOGoal(dictionary: idMissingGoalJSON)
        XCTAssertNil(goal, "Goal must be nil when id is not present in JSON")
    }

    func testMissingKeyIdentifier() {
        let identifierMissingGoalJSON = """
        {
            "type": "REVENUE_TRACKING",
            "id": 1
        }
        """.jsonToDictionary
        let goal = VWOGoal(dictionary: identifierMissingGoalJSON)
        XCTAssertNil(goal, "Goal must be nil when identifier is not present in JSON")
    }
}
