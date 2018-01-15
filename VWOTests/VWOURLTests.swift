//
//  VWOURLTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 15/01/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest

class VWOURLTests: XCTestCase {
    let apiKey = "f9066ca73d6564484560a83b63658605-295084"
    let userDefaultskey = "someKeyURL"

    func testForFetchingCampaigns() {
        let config = VWOConfig(apiKey: apiKey, userDefaultsKey: userDefaultskey)
        let url = VWOURL.forFetchingCampaignsConfig(config)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        XCTAssertEqual(components.host, "dacdn.visualwebsiteoptimizer.com")
        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.path, "/mobile")

        let queryItems = components.queryItems!
        XCTAssertEqual(queryItems.count, 9)
        for query in queryItems {
            if query.name == "a" {
                XCTAssertEqual(query.value!, "295084")
            }
        }
    }

    func testsForMakingUserPartOfCampaign() {
        let config = VWOConfig(apiKey: apiKey, userDefaultsKey: userDefaultskey)
        let campaign1 = VWOCampaign(dictionary: JSONFrom(file: "Campaign1"))!

        let url = VWOURL.forMakingUserPart(of: campaign1, config: config, dateTime: Date.distantFuture)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        XCTAssertEqual(components.path, "/track-user")
        let queryNameList = components.queryItems!.map { $0.name}
        XCTAssert(queryNameList.contains("experiment_id"))
        XCTAssert(queryNameList.contains("account_id"))
    }

    func testForMarkingGoal1() {
        let config = VWOConfig(apiKey: apiKey, userDefaultsKey: userDefaultskey)
        let campaign1 = VWOCampaign(dictionary: JSONFrom(file: "Campaign1"))!
        let goal = VWOGoal(dictionary: JSONFrom(file: "Goal1"))!

        // Case where goal value is nil
        let url = VWOURL.forMarking(goal, withValue: nil, campaign: campaign1, dateTime: Date(), config: config)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryNameList = components.queryItems!.map { $0.name}
        XCTAssertFalse(queryNameList.contains("r"))
    }

    func testForMarkingGoal2() {
        let config = VWOConfig(apiKey: apiKey, userDefaultsKey: userDefaultskey)
        let campaign1 = VWOCampaign(dictionary: JSONFrom(file: "Campaign1"))!
        let goal = VWOGoal(dictionary: JSONFrom(file: "Goal1"))!

        // Case where goal has a valid value
        let url = VWOURL.forMarking(goal, withValue: 123, campaign: campaign1, dateTime: Date(), config: config)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryNameList = components.queryItems!.map { $0.name}
        XCTAssert(queryNameList.contains("r"))
    }
}
