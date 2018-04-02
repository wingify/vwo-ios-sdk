//
//  VWOConfigTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 12/01/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest

class VWOConfigTests: XCTestCase {

    let userDefaultskey = "someKey"
    let campaign1 = VWOCampaign(dictionary: JSONFrom(file: "Campaign1"))!
    let campaign2 = VWOCampaign(dictionary: JSONFrom(file: "Campaign2"))!

    override func setUp() {
        UserDefaults.standard.removeObject(forKey: userDefaultskey)
        XCTAssertNil(UserDefaults.standard.value(forKey: userDefaultskey))
        VWOUserDefaults.setDefaultsKey(userDefaultskey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: userDefaultskey)
    }

    func testInitialConfig() {

        XCTAssertFalse(VWOUserDefaults.isReturningUser)
        XCTAssertNotNil(VWOUserDefaults.uuid)
        XCTAssertEqual(VWOUserDefaults.uuid.count, 32)
        XCTAssertEqual(VWOUserDefaults.sessionCount, 0)
    }

    func testUpdateReturningUser() {
        XCTAssertFalse(VWOUserDefaults.isReturningUser)
        VWOUserDefaults.trackUser(for: campaign1)
        VWOUserDefaults.sessionCount = 2
        XCTAssertTrue(VWOUserDefaults.isReturningUser)
    }

    func testIsTracking() {
        XCTAssertFalse(VWOUserDefaults.isTrackingUser(for: campaign1))
        VWOUserDefaults.trackUser(for: campaign1)
        XCTAssertTrue(VWOUserDefaults.isTrackingUser(for: campaign1))
    }

    func testIsTrackingExcludedCampaign() {
        let campaign = VWOCampaign(dictionary: JSONFrom(file: "CampaignExcluded"))!
        VWOUserDefaults.trackUser(for: campaign)
        let dict = VWOUserDefaults.campaignVariationPairs as! [String : Int]
        XCTAssertEqual(dict, ["17": 0])
    }

    func testCampaignPairs() {
        VWOUserDefaults.trackUser(for: campaign1)
        VWOUserDefaults.trackUser(for: campaign2)

        let dict = VWOUserDefaults.campaignVariationPairs as! [String : Int]
        XCTAssertEqual(dict, ["15": 3, "16": 7])
    }

    func testTrackUser() {
        XCTAssertFalse(VWOUserDefaults.isTrackingUser(for: campaign1))
        VWOUserDefaults.trackUser(for: campaign1)
        XCTAssertTrue(VWOUserDefaults.isTrackingUser(for: campaign1))
    }

    func testTrackUserCampaignExcluded() {
        let campaign = VWOCampaign(dictionary: JSONFrom(file: "CampaignExcluded"))!

        XCTAssertFalse(VWOUserDefaults.isTrackingUser(for: campaign))
        VWOUserDefaults.trackUser(for: campaign)
        XCTAssertTrue(VWOUserDefaults.isTrackingUser(for: campaign))
    }

    func testMarkGoalConversion() {
        let goal1 = VWOGoal(dictionary: JSONFrom(file: "Goal1"))!
        let goal2 = VWOGoal(dictionary: JSONFrom(file: "Goal2"))!

        VWOUserDefaults.markGoalConversion(goal1, in: campaign1)
        XCTAssert(VWOUserDefaults.isGoalMarked(goal1, in: campaign1))
        XCTAssertFalse(VWOUserDefaults.isGoalMarked(goal1, in: campaign2))

        XCTAssertFalse(VWOUserDefaults.isGoalMarked(goal2, in: campaign1))
        XCTAssertFalse(VWOUserDefaults.isGoalMarked(goal2, in: campaign2))

        VWOUserDefaults.markGoalConversion(goal2, in: campaign1)
        XCTAssert(VWOUserDefaults.isGoalMarked(goal2, in: campaign1))
        XCTAssertFalse(VWOUserDefaults.isGoalMarked(goal2, in: campaign2))
    }
}
