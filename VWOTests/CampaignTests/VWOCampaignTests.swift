//
//  VWOCampaignTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 10/01/18.
//  Copyright © 2018-2022 vwo. All rights reserved.
//

import XCTest

class VWOCampaignTests : XCTestCase {
    func testCampaignCreation() {
        let campaignJSON = JSONFrom(file: "Campaign1")
        let campaign = VWOCampaign(dictionary: campaignJSON)
        XCTAssertNotNil(campaign)
        XCTAssertEqual(campaign!.name, "Campaign 15")
        XCTAssertEqual(campaign!.iD, 15)
        XCTAssertTrue(campaign!.trackUserOnLaunch)
        XCTAssertEqual(campaign!.status, .running)
        XCTAssertEqual(campaign!.variation.name, "Variation-2")
        XCTAssertEqual(campaign!.goals.count, 2)
    }

    func testCampaignCreation2() {
        //Here track user on launch is false
        let campaignJSON = JSONFrom(file: "Campaign2")
        let campaign = VWOCampaign(dictionary: campaignJSON)
        XCTAssertNotNil(campaign)
        XCTAssertEqual(campaign!.name, "My Campaign")
        XCTAssertFalse(campaign!.trackUserOnLaunch)
    }

    func testVariationForKey() {
        let campaignJSON = JSONFrom(file: "Campaign1")
        let campaign = VWOCampaign(dictionary: campaignJSON)
        XCTAssertEqual(campaign!.variation(forKey: "socialMedia") as! Bool, true)
        XCTAssertEqual(campaign!.variation(forKey: "layout") as! String, "grid")
        XCTAssertNil(campaign!.variation(forKey: "invalidKey"))
    }

    func testGoalForIdentifier() {
        let campaignJSON = JSONFrom(file: "Campaign1")
        let campaign = VWOCampaign(dictionary: campaignJSON)

        let landingGoal = campaign!.goal(forIdentifier: "landingPage")
        XCTAssertNotNil(landingGoal!)
        XCTAssertEqual(landingGoal!.iD, 1)
        XCTAssertEqual(landingGoal!.type, .revenue)

        let productViewGoal = campaign!.goal(forIdentifier: "productView")
        XCTAssertNotNil(productViewGoal!)
        XCTAssertEqual(productViewGoal!.iD, 201)
        XCTAssertEqual(productViewGoal!.type, .custom)

        let nilGoal = campaign!.goal(forIdentifier: "someInvalidID")
        XCTAssertNil(nilGoal)
    }

    func testPausedCampaign() {
        let campaignJSON = JSONFrom(file: "CampaignPaused")
        let campaign = VWOCampaign(dictionary: campaignJSON)
        XCTAssertNotNil(campaign)
        XCTAssertEqual(campaign!.iD, 11)
        XCTAssertEqual(campaign!.status, .paused)
    }

    func testExcludedCampaign() {
        let campaignExcluding = VWOCampaign(dictionary: JSONFrom(file: "CampaignExcluded"))
        XCTAssertNotNil(campaignExcluding)
        XCTAssertEqual(campaignExcluding!.status, .excluded)
        XCTAssertEqual(campaignExcluding!.name, "Excl")
    }

    func testMissingKeys() {
        let campaignIDMissing = VWOCampaign(dictionary: JSONFrom(file: "CampaignIDMissing"))
        XCTAssertNil(campaignIDMissing)
        let campaignStatusMissing = VWOCampaign(dictionary: JSONFrom(file: "CampaignStatusMissing"))
        XCTAssertNil(campaignStatusMissing)
    }

    func testMissingKeysInRunningCampaign() {
        let campaign = VWOCampaign(dictionary: JSONFrom(file: "CampaignRunningKeysMissing"))
        XCTAssertNil(campaign)
    }
}
