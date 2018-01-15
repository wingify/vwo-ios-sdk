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
    let apiKey = "f9066ca73d6564484560a83b63658605-295084"

    override func setUp() { }

    override func tearDown() { }

    func testInitialConfig() {
        UserDefaults.standard.removeObject(forKey: userDefaultskey)
        XCTAssertNil(UserDefaults.standard.value(forKey: userDefaultskey))
        let config = VWOConfig(apiKey: apiKey, userDefaultsKey: userDefaultskey)
        XCTAssertEqual(config.accountID, "295084")
        XCTAssertEqual(config.appKey, "f9066ca73d6564484560a83b63658605")
        XCTAssertFalse(config.isReturningUser)
        XCTAssertNotNil(config.uuid)
        XCTAssertEqual(config.uuid.count, 32)
        XCTAssertEqual(config.sessionCount, 0)
    }

    func testReturningUser() {
        UserDefaults.standard.removeObject(forKey: userDefaultskey)
        XCTAssertNil(UserDefaults.standard.value(forKey: userDefaultskey))
        let config = VWOConfig(apiKey: apiKey, userDefaultsKey: userDefaultskey)
        XCTAssertFalse(config.isReturningUser)
        config.isReturningUser = true
        XCTAssertTrue(config.isReturningUser)
    }

    func testTwiceInitialization() {
        // If config is initialized twice then user defaults must not reset
        UserDefaults.standard.removeObject(forKey: userDefaultskey)
        XCTAssertNil(UserDefaults.standard.value(forKey: userDefaultskey))
        var config = VWOConfig(apiKey: apiKey, userDefaultsKey: userDefaultskey)
        config.sessionCount = 100
        config = VWOConfig(apiKey: apiKey, userDefaultsKey: userDefaultskey)
        XCTAssertEqual(config.sessionCount, 100)
    }

    func testIsTracking() {
        UserDefaults.standard.removeObject(forKey: userDefaultskey)
        XCTAssertNil(UserDefaults.standard.value(forKey: userDefaultskey))

        let config = VWOConfig(apiKey: apiKey, userDefaultsKey: userDefaultskey)
        let runningCampaign = VWOCampaign()
        runningCampaign.iD = 1
        runningCampaign.status = .running
        XCTAssertFalse(config.isTrackingUser(for: runningCampaign))
        //TODO: Why is this working with variation not set in campaign
        config.trackUser(for: runningCampaign)
        XCTAssertTrue(config.isTrackingUser(for: runningCampaign))

    }

    func testIsTrackingExcludedCampaign() {
        UserDefaults.standard.removeObject(forKey: userDefaultskey)
        XCTAssertNil(UserDefaults.standard.value(forKey: userDefaultskey))

        //For Excluded campaigns it must return store 0
        let config = VWOConfig(apiKey: apiKey, userDefaultsKey: userDefaultskey)

        let campaign = VWOCampaign()
        campaign.iD = 1
        campaign.status = .excluded
        let variation = VWOVariation()
        variation.iD = 123 //Instead of 123 0 must be stored
        campaign.variation = variation
        config.trackUser(for: campaign)
        let dict = config.campaignVariationPairs as! [String : Int]
        XCTAssertEqual(dict, ["1": 0])
    }

    func testCampaignPairs() {
        UserDefaults.standard.removeObject(forKey: userDefaultskey)
        XCTAssertNil(UserDefaults.standard.value(forKey: userDefaultskey))
        let config = VWOConfig(apiKey: apiKey, userDefaultsKey: userDefaultskey)

        let campaign1 = VWOCampaign()
        campaign1.iD = 1
        campaign1.status = .running
        let variation = VWOVariation()
        variation.iD = 123
        campaign1.variation = variation

        let campaign2 = VWOCampaign()
        campaign2.iD = 2
        campaign2.status = .running
        let variation1 = VWOVariation()
        variation1.iD = 7654
        campaign2.variation = variation1

        config.trackUser(for: campaign1)
        config.trackUser(for: campaign2)

        let dict = config.campaignVariationPairs as! [String : Int]
        XCTAssertEqual(dict, ["1": 123, "2": 7654])
    }

    func testTrackUser() {
        UserDefaults.standard.removeObject(forKey: userDefaultskey)
        XCTAssertNil(UserDefaults.standard.value(forKey: userDefaultskey))
        let config = VWOConfig(apiKey: apiKey, userDefaultsKey: userDefaultskey)

        let campaign1 = VWOCampaign(dictionary: JSONFrom(file: "Campaign1"))
        let campaign2 = VWOCampaign(dictionary: JSONFrom(file: "Campaign2"))

    }
    func testMarkGoalConversion() {
        UserDefaults.standard.removeObject(forKey: userDefaultskey)
        XCTAssertNil(UserDefaults.standard.value(forKey: userDefaultskey))
        let config = VWOConfig(apiKey: apiKey, userDefaultsKey: userDefaultskey)

        let campaign1 = VWOCampaign()
        campaign1.iD = 1

        let campaign2 = VWOCampaign()
        campaign2.iD = 2

        let goal1 = VWOGoal()
        goal1.iD = 211

        let goal2 = VWOGoal()
        goal2.iD = 311

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
