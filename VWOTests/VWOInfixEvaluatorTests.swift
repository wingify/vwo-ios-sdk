//
//  VWOInfixEvaluatorTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 09/01/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest
class VWOInfixEvaluatorTests: XCTestCase {
    func testEvaluator() {
        XCTAssertTrue(VWOInfixEvaluator().evaluate("1".map {"\($0)"}))
        XCTAssertFalse(VWOInfixEvaluator().evaluate( "0".map {"\($0)"}))
        XCTAssertTrue(VWOInfixEvaluator().evaluate("(1)".map {"\($0)"}))
        XCTAssertFalse(VWOInfixEvaluator().evaluate("(0)".map {"\($0)"}))
        XCTAssertTrue(VWOInfixEvaluator().evaluate("1|0".map {"\($0)"}))
        XCTAssertTrue(VWOInfixEvaluator().evaluate("1&1".map {"\($0)"}))
        XCTAssertFalse(VWOInfixEvaluator().evaluate("1&0".map {"\($0)"}))
        XCTAssertFalse(VWOInfixEvaluator().evaluate("(1&0)".map {"\($0)"}))
        XCTAssertFalse(VWOInfixEvaluator().evaluate("(1)&(0)".map {"\($0)"}))
        XCTAssertTrue(VWOInfixEvaluator().evaluate("(1&0|1)".map {"\($0)"}))
        XCTAssertTrue(VWOInfixEvaluator().evaluate("(1&1|0)".map {"\($0)"}))
        XCTAssertTrue(VWOInfixEvaluator().evaluate("(1&1|0)&1".map {"\($0)"}))
        XCTAssertFalse(VWOInfixEvaluator().evaluate("(1&1|0)&0".map {"\($0)"}))
        XCTAssertTrue(VWOInfixEvaluator().evaluate("(1&1|0)&(0|1)".map {"\($0)"}))

        XCTAssertTrue(VWOInfixEvaluator().evaluate("((1))".map {"\($0)"}))
        XCTAssertFalse(VWOInfixEvaluator().evaluate("(((0)))".map {"\($0)"}))
        XCTAssertFalse(VWOInfixEvaluator().evaluate("((1)&(0))".map {"\($0)"}))
        XCTAssertFalse(VWOInfixEvaluator().evaluate("((1)&(0)&1)".map {"\($0)"}))
        XCTAssertTrue(VWOInfixEvaluator().evaluate("((1&0)|1)".map {"\($0)"}))

    }
}
