//
//  VWOVariationTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 22/11/17.
//  Copyright © 2017 vwo. All rights reserved.
//

import XCTest

class VWOVariationTests: XCTestCase {
    func testVariationInitiser() {
        let json = """
        {
            "changes": {
                "skip": true,
                "layout": "grid",
                "details": {
                    "gender": "male",
                    "age": 28
                },
                "name": [
                    "A",
                    "B",
                    "C"
                ],
                "test": true
            },
            "weight": 100,
            "name": "Variation-1",
            "id": "2"
        }
        """.jsonToDictionary
        let variation = VWOVariation(dictionary: json)
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
        let json = """
        {
            "changes": {
                "skip": null,
                "test": null,
                "details": null,
                "name": null,
                "layout": null
            },
            "weight": 100,
            "name": "Control",
            "id": "1"
        }
        """.jsonToDictionary
        let variation = VWOVariation(dictionary: json)
        XCTAssertNotNil(variation)
        XCTAssertTrue(variation!.isControl())
        XCTAssertNotNil(variation!.changes)
    }

    func testMissingKeys() {
        let json = """
        {
            "changes": {
                "skip": true,
                "layout": "grid"
            },
            "weight": 100,
            "id": "2"
        }
        """.jsonToDictionary
        let variation = VWOVariation(dictionary: json)
        XCTAssertNil(variation)
    }
}

