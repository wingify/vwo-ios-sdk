//
//  VWOSegmentTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 09/01/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest
class VWOSegmentTests: XCTestCase {
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
