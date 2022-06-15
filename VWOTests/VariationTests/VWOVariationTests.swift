//
//  VWOVariationTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 22/11/17.
//  Copyright © 2017-2022 vwo. All rights reserved.
//

import XCTest

class VWOVariationTests: XCTestCase {
    func testVariationInitiser() {
        let variation = VWOVariation(dictionary: JSONFrom(file: "Variation1"))
        XCTAssertNotNil(variation)
        XCTAssertNotNil(variation!.name)
        XCTAssertEqual(variation!.name, "Variation-1")
        XCTAssertEqual(variation!.iD, 2)
        XCTAssertFalse(variation!.isControl())
        XCTAssertEqual(variation!.changes!["skip"] as! Bool, true)
        XCTAssertEqual(variation!.changes!["layout"] as! String, "grid")
        XCTAssertNotNil(variation!.changes!["name"] as? [String])
        XCTAssertNotNil(variation!.changes!["details"] as? [String: Any])
    }

    func testIsControl() {
        let variation = VWOVariation(dictionary: JSONFrom(file: "VarationControl"))
        XCTAssertNotNil(variation)
        XCTAssertTrue(variation!.isControl())
        XCTAssertNotNil(variation!.changes)
    }

    func testMissingKeys() {
        let variation = VWOVariation(dictionary: JSONFrom(file: "VariationMissingKeys"))
        XCTAssertNil(variation)
    }
}
