//
//  VWOSegmentTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 09/01/18.
//  Copyright © 2018-2022 vwo. All rights reserved.
//

import XCTest
class VWOSegmentTests: XCTestCase {

    func testInitializationFailure() {
        let json: [String : Any] = [ "type": "3", "operator": 11, "rOperandValue": [0]]
        XCTAssertNotNil(VWOSegment(dictionary: json))

        let json1: [String : Any] = [String : Any]()
        XCTAssertNil(VWOSegment(dictionary: json1), "Should not initialize when dictionary is missing")

        let json2: [String : Any] = ["operator": 11, "rOperandValue": [0]]
        XCTAssertNil(VWOSegment(dictionary: json2), "Should not initialize when type is missing")

        let json3: [String : Any] = [ "type": "3", "rOperandValue": [0]]
        XCTAssertNil(VWOSegment(dictionary: json3), "Should not initialize when operator is missing")

        let json4: [String : Any] = [ "type": "3", "operator": 11]
        XCTAssertNil(VWOSegment(dictionary: json4), "Should not initialize when rOperandValue is missing")

        let json5: [String : Any] = [ "type": 123, "operator": 11, "rOperandValue": [0]]
        XCTAssertNil(VWOSegment(dictionary: json5), "Should not initialize when type is not string")

        let json6: [String : Any] = [ "type": 123, "operator": 11, "rOperandValue": [0], "prevLogicalOperator": "INVALID"]
        XCTAssertNil(VWOSegment(dictionary: json6), "Should not initialize when previouslogical operaor is invalid")
    }

    //MARK: - Infix Tests
    func test1() {
        let segment = VWOSegment()
        XCTAssertEqual(segment.toInfix(forOperand: true), ["1"])
    }
    func test11() {
        let segment = VWOSegment()
        XCTAssertEqual(segment.toInfix(forOperand: false), ["0"])
    }
    func test2() {
        let segment = VWOSegment()
        segment.previousLogicalOperator = .and
        XCTAssertEqual(segment.toInfix(forOperand: true), ["&", "1"])
    }
    func test21() {
        let segment = VWOSegment()
        segment.previousLogicalOperator = .and
        segment.rightBracket = true
        XCTAssertEqual(segment.toInfix(forOperand: true), ["&", "1", ")"])
    }
    func test3() {
        let segment = VWOSegment()
        segment.previousLogicalOperator = .and
        segment.leftBracket = true
        XCTAssertEqual(segment.toInfix(forOperand: true), ["&", "(", "1"])
    }
    func test4() {
        let segment = VWOSegment()
        segment.previousLogicalOperator = .and
        segment.leftBracket = true
        segment.rightBracket = true
        XCTAssertEqual(segment.toInfix(forOperand: true), ["&", "(", "1", ")"])
    }
    func test41() {
        let segment = VWOSegment()
        segment.leftBracket = true
        segment.rightBracket = true
        XCTAssertEqual(segment.toInfix(forOperand: true), ["(", "1", ")"])
    }
    func test5() {
        let segment = VWOSegment()
        segment.leftBracket = true
        segment.rightBracket = true
        XCTAssertEqual(segment.toInfix(forOperand: true), ["(", "1", ")"])
    }
}
