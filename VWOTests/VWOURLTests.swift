//
//  VWOURLTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 15/01/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest

class VWOURLTests: XCTestCase {
    let userDefaultskey = "someKeyURL"
    let vwoURL = VWOURL(appKey: "f9066ca73d6564484560a83b63658605", accountID: "295084", isChinaCDN: false)

    override func setUp() {
        UserDefaults.standard.removeObject(forKey: userDefaultskey)
        XCTAssertNil(UserDefaults.standard.value(forKey: userDefaultskey))
        VWOUserDefaults.setDefaultsKey(userDefaultskey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: userDefaultskey)
    }

    func testForFetchingCampaigns() {
        VWOUserDefaults.setDefaultsKey(userDefaultskey)
        let url = vwoURL.forFetchingCampaigns(nil)
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
//
//    func testsForMakingUserPartOfCampaign() {
//        let campaign1 = VWOCampaign(dictionary: JSONFrom(file: "Campaign1"))!
//        let url = vwoURL.forMakingUserPart(of: campaign1, dateTime: Date.distantFuture)
//        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
//
//        XCTAssertEqual(components.path, "/track-user")
//        let queryNameList = components.queryItems!.map { $0.name}
//        XCTAssert(queryNameList.contains("experiment_id"))
//        XCTAssert(queryNameList.contains("account_id"))
//    }

    func testForMarkingGoal1() {
        let campaign1 = VWOCampaign(dictionary: JSONFrom(file: "Campaign1"))!
        let goal = VWOGoal(dictionary: JSONFrom(file: "Goal1"))!

        // Case where goal value is nil
        let url = vwoURL.forMarking(goal, withValue: nil, campaign: campaign1, dateTime: Date())
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryNameList = components.queryItems!.map { $0.name}
        XCTAssertFalse(queryNameList.contains("r"))
    }

    func testForMarkingGoal2() {
        let campaign1 = VWOCampaign(dictionary: JSONFrom(file: "Campaign1"))!
        let goal = VWOGoal(dictionary: JSONFrom(file: "Goal1"))!

        // Case where goal has a valid value
        let url = vwoURL.forMarking(goal, withValue: 123, campaign: campaign1, dateTime: Date())
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryNameList = components.queryItems!.map { $0.name}
        XCTAssert(queryNameList.contains("r"))
    }
    
    func testCustomDimension() {
        let url = vwoURL.forPushingCustomDimension("key", withCustomDimensionValue: "value", dateTime: Date())
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryNameList = components.queryItems!.map { $0.name}
        XCTAssert(queryNameList.contains("tags"))
    }
    
    func testUserId() {
        var url = vwoURL.forFetchingCampaigns("userId")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryNameList = components.queryItems!.map { $0.name}
        XCTAssert(queryNameList.contains("uHash"))
        var userID = ""
        for query in components.queryItems! {
            if query.name == "uHash" {
                userID = query.value!
            }
        }
        
        
        url = vwoURL.forPushingCustomDimension("key", withCustomDimensionValue: "value", dateTime: Date())
        components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        queryNameList = components.queryItems!.map { $0.name}
        for query in components.queryItems! {
            if query.name == "u" {
                XCTAssertEqual(query.value!, userID)
            }
        }
        XCTAssert(queryNameList.contains("tags"))
    }
    
    func testWithoutUserId() {
        var url = vwoURL.forFetchingCampaigns(nil)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryNameList = components.queryItems!.map { $0.name}
        XCTAssertFalse(queryNameList.contains("uHash"))
        let userID = ""
        
        
        url = vwoURL.forPushingCustomDimension("key", withCustomDimensionValue: "value", dateTime: Date())
        components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        queryNameList = components.queryItems!.map { $0.name}
        for query in components.queryItems! {
            if query.name == "u" {
                XCTAssertNotEqual(query.value!, userID)
            }
        }
    }
}

