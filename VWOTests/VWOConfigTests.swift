//
//  VWOConfigTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 12/01/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest

class VWOConfigTests: XCTestCase {

    var config: VWOUserDefaults!
    let userDefaultskey = "someKey"
    let apiKey = "f9066ca73d6564484560a83b63658605-295084"
    let campaign1 = VWOCampaign(dictionary: JSONFrom(file: "Campaign1"))!
    let campaign2 = VWOCampaign(dictionary: JSONFrom(file: "Campaign2"))!

    override func setUp() {
        UserDefaults.standard.removeObject(forKey: userDefaultskey)
        XCTAssertNil(UserDefaults.standard.value(forKey: userDefaultskey))
        config = VWOUserDefaults(apiKey: apiKey, userDefaultsKey: userDefaultskey)
        XCTAssertNotNil(config)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: userDefaultskey)
    }

    func testInitialConfig() {
        XCTAssertEqual(config.accountID, "295084")
        XCTAssertEqual(config.appKey, "f9066ca73d6564484560a83b63658605")
        XCTAssertFalse(config.isReturningUser)
        XCTAssertNotNil(config.uuid)
        XCTAssertEqual(config.uuid.count, 32)
        XCTAssertEqual(config.sessionCount, 0)
    }

    func testUpdateReturningUser() {
        XCTAssertFalse(config.isReturningUser)
        config.trackUser(for: campaign1)
        config.sessionCount = 2
        XCTAssertTrue(config.isReturningUser)
    }

    func testTwiceInitialization() {
        config.sessionCount = 100
        config = VWOUserDefaults(apiKey: apiKey, userDefaultsKey: userDefaultskey)
        XCTAssertEqual(config.sessionCount, 100)
    }

    func testIsTracking() {
        XCTAssertFalse(config.isTrackingUser(for: campaign1))
        config.trackUser(for: campaign1)
        XCTAssertTrue(config.isTrackingUser(for: campaign1))
    }

    func testIsTrackingExcludedCampaign() {
        let campaign = VWOCampaign(dictionary: JSONFrom(file: "CampaignExcluded"))!
        config.trackUser(for: campaign)
        let dict = config.campaignVariationPairs as! [String : Int]
        XCTAssertEqual(dict, ["17": 0])
    }

    func testCampaignPairs() {
        config.trackUser(for: campaign1)
        config.trackUser(for: campaign2)

        let dict = config.campaignVariationPairs as! [String : Int]
        XCTAssertEqual(dict, ["15": 3, "16": 7])
    }

    func testTrackUser() {
        XCTAssertFalse(config.isTrackingUser(for: campaign1))
        config.trackUser(for: campaign1)
        XCTAssertTrue(config.isTrackingUser(for: campaign1))
    }

    func testTrackUserCampaignExcluded() {
        let campaign = VWOCampaign(dictionary: JSONFrom(file: "CampaignExcluded"))!

        XCTAssertFalse(config.isTrackingUser(for: campaign))
        config.trackUser(for: campaign)
        XCTAssertTrue(config.isTrackingUser(for: campaign))
    }

    func testMarkGoalConversion() {
        let goal1 = VWOGoal(dictionary: JSONFrom(file: "Goal1"))!
        let goal2 = VWOGoal(dictionary: JSONFrom(file: "Goal2"))!

        config.markGoalConversion(goal1, in: campaign1)
        XCTAssert(config.isGoalMarked(goal1, in: campaign1))
        XCTAssertFalse(config.isGoalMarked(goal1, in: campaign2))

        XCTAssertFalse(config.isGoalMarked(goal2, in: campaign1))
        XCTAssertFalse(config.isGoalMarked(goal2, in: campaign2))

        config.markGoalConversion(goal2, in: campaign1)
        XCTAssert(config.isGoalMarked(goal2, in: campaign1))
        XCTAssertFalse(config.isGoalMarked(goal2, in: campaign2))
    }
}
