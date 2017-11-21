//
//  VWODictionaryTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 21/11/17.
//  Copyright © 2017 vwo. All rights reserved.
//

import XCTest
import UIKit

class VWODictionaryTests: XCTestCase {

    override func setUp() { super.setUp() }

    override func tearDown() { super.tearDown() }

    func testKeysMissingFromDictionary() {
        let dict = ["a" : 1, "b" : 2, "c" : 3] as NSDictionary
        XCTAssertEqual(dict.keysMissing(from: ["a", "b", "c"]), [])
        XCTAssertEqual(dict.keysMissing(from: ["a", "b", "c", "d"]), ["d"])
        XCTAssertEqual(dict.keysMissing(from: ["a", "b", "c", "d", "e"]), ["d", "e"])
        XCTAssertEqual(dict.keysMissing(from: ["a", "b"]), [])
        XCTAssertEqual(dict.keysMissing(from: ["a1", "b1"]), ["a1", "b1"])
    }

    func testToString() {
        XCTAssertEqual((["a" : 1, "b" : 2, "c" : 3] as NSDictionary).toString()!,
                       "{\"a\":1,\"b\":2,\"c\":3}")
        XCTAssertEqual((["name" : "Kaunteya", "details" : ["age" : 1, "gender" : "male"]] as NSDictionary).toString()!,
                       "{\"name\":\"Kaunteya\",\"details\":{\"age\":1,\"gender\":\"male\"}}")
    }

    func testToQueryItem() {
        XCTAssertEqual((["name" : "Kaunteya", "age" : "1", "gender" : "male"] as NSDictionary).toQueryItems(),
                       [URLQueryItem(name: "name", value: "Kaunteya"),
                        URLQueryItem(name: "age", value: "1"),
                        URLQueryItem(name: "gender", value: "male")]
        )
        XCTAssertEqual((["name" : "Kaunteya"] as NSDictionary).toQueryItems(),
                       [URLQueryItem(name: "name", value: "Kaunteya")])
    }
}
