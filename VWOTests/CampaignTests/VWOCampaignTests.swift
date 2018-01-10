//
//  VWOCampaignTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 10/01/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest

class VWOCampaignTests : XCTestCase {
    func testCampaign() {
        let campaignJSON = JSONFrom(file: "Campaign1")
        let campaign = VWOCampaign(dictionary: campaignJSON)
        XCTAssertNotNil(campaign)
        XCTAssertEqual(campaign!.name, "Campaign 15")
        XCTAssertEqual(campaign!.iD, 15)
        XCTAssertTrue(campaign!.trackUserOnLaunch)
        XCTAssertEqual(campaign!.status, .running)
        XCTAssertEqual(campaign!.variation.name, "Variation-2")
        XCTAssertEqual(campaign!.goals.count, 2)
        XCTAssertEqual(campaign!.variation(forKey: "socialMedia") as! Bool, true)
        XCTAssertEqual(campaign!.variation(forKey: "layout") as! String, "grid")

        let landingGoal = campaign!.goal(forIdentifier: "landingPage")
        XCTAssertNotNil(landingGoal!)
        XCTAssertEqual(landingGoal!.iD, 1)
        XCTAssertEqual(landingGoal!.type, .revenue)
        let productViewGoal = campaign!.goal(forIdentifier: "productView")
        XCTAssertNotNil(productViewGoal!)
        XCTAssertEqual(productViewGoal!.iD, 201)
        XCTAssertEqual(productViewGoal!.type, .custom)
    }

    func testPausedCampaign() {
        let campaignJSON = JSONFrom(file: "CampaignPaused")
        let campaign = VWOCampaign(dictionary: campaignJSON)
        XCTAssertNotNil(campaign)
        XCTAssertEqual(campaign!.iD, 11)
        XCTAssertEqual(campaign!.status, .paused)

    }
}
