//
//  VWOGoalTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 22/11/17.
//  Copyright © 2017-2022 vwo. All rights reserved.
//

import XCTest
class VWOGOalTests: XCTestCase {

    func testCustomGoalInitialiser() {
        let goal = VWOGoal(dictionary: JSONFrom(file: "Goal1"))
        XCTAssertNotNil(goal)
        XCTAssertEqual(goal!.type, .custom)
        XCTAssertNotNil(goal!.identifier)
        XCTAssertEqual(goal!.identifier, "newGoal")
        XCTAssertEqual(goal!.iD, 12)
    }

    func testRevenueInitialiser() {
        let goal = VWOGoal(dictionary: JSONFrom(file: "Goal2"))
        XCTAssertNotNil(goal)
        XCTAssertEqual(goal!.type, .revenue)
        XCTAssertNotNil(goal!.identifier)
        XCTAssertEqual(goal!.identifier, "goal45")
        XCTAssertEqual(goal!.iD, 1)
    }

    func testMissingKeyId() {
        let goal = VWOGoal(dictionary: JSONFrom(file: "GoalIdMissing"))
        XCTAssertNil(goal, "Goal must be nil when id is not present in JSON")
    }

    func testMissingKeyIdentifier() {
        let goal = VWOGoal(dictionary: JSONFrom(file: "GoalIdentifierMissing"))
        XCTAssertNil(goal, "Goal must be nil when identifier is not present in JSON")
    }
}
