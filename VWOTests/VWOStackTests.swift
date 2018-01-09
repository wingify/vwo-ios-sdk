//
//  VWOStackTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 09/01/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest

class VWOStackTests: XCTestCase {
    func testCreation() {
        let stack = VWOStack()
        XCTAssertNotNil(stack)
    }
    func testPush() {
        let stack = VWOStack()
        stack.push("A")
        stack.push("B")
        XCTAssertEqual(stack.count, 2)
        XCTAssertNotNil(stack.peek as? String)
        XCTAssertEqual(stack.peek as! String, "B")
    }
    func testPop() {
        let stack = VWOStack()
        stack.push("A")
        stack.push("B")
        XCTAssertEqual(stack.pop() as! String, "B")
        XCTAssertEqual(stack.pop() as! String, "A")
        XCTAssertNil(stack.pop())
    }
    func testIsEmpty() {
        let stack = VWOStack()
        XCTAssertTrue(stack.isEmpty())
        stack.push("A")
        stack.push("B")
        XCTAssertFalse(stack.isEmpty())
    }
    func testPeek() {
        let stack = VWOStack()
        stack.push("A")
        stack.push("B")
        XCTAssertEqual(stack.peek as! String, "B")
        XCTAssertEqual(stack.count, 2)
    }
    func testCount() {
        let stack = VWOStack()
        XCTAssertEqual(stack.count, 0)
        stack.push("A")
        XCTAssertEqual(stack.count, 1)
        stack.push("B")
        XCTAssertEqual(stack.count, 2)
    }
}
