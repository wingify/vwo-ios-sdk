//
//  VWOQueueTests.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 21/11/17.
//  Copyright © 2017 vwo. All rights reserved.
//

import XCTest

class VWOQueueTests: XCTestCase {
    var vwoQueue: VWOQueue!

    var path: URL? {
        let path = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return path?.appendingPathComponent("TestQueue.plist")
    }

    override func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: path!)
        XCTAssertNotNil(path)
        XCTAssertFalse(FileManager.default.fileExists(atPath: path!.path), "File must be deleted before every test case")
        vwoQueue = VWOQueue(fileURL: path!)
    }

    override func tearDown() {
        super.tearDown()
        try! FileManager.default.removeItem(at: path!)
    }

    func testAllBasic() {

    }
    func insert100ElementsinQueue() {
        for i in 0..<100 {
            vwoQueue.enqueue(["a" : i])
        }

    }
    func testEnqueue() {
        XCTAssertEqual(vwoQueue.count, 0)
        insert100ElementsinQueue()
        XCTAssertEqual(vwoQueue.count, 100)
    }

    func testDeQueue() {
        insert100ElementsinQueue()
        //Dequeue
        for _ in 0..<vwoQueue.count {
            vwoQueue.dequeue()
        }
        XCTAssertEqual(vwoQueue.count, 0)
        XCTAssertNil(vwoQueue.dequeue())

    }
    func testPeek() {
        XCTAssertNil(vwoQueue.peek)
        vwoQueue.enqueue(["a" : "b"])
        XCTAssertEqual(vwoQueue.peek as! [String : String], ["a" : "b"])
    }

    func testInsertionLargeDictionary() {
        var dict = [String : Any]()
        for i in 0..<100 {
            dict["lksjdflkjasdlkfjaslkdfjlsdkjfklsdjfklsjflkasjdfksdjflksjdfasdfasdf\(i)"] = "ASDFADFSFDGHSAGDDGHGSDlsjflkasjdfksdjflksjdfasdfasdf\(i)"
        }
        for _ in 0..<100 {
            vwoQueue.enqueue(dict)
        }
        XCTAssertEqual(vwoQueue.count, 100)
    }

    func testMultiThreadedInsertion() {
        var largeDict = [String : Any]()
        for i in 0..<100 {
            largeDict["lksjdflkjasdlkfjaslkdfjlsdkjfklsdjfklsjflkasjdfksdjflksjdfasdfasdf\(i)"] = "ASDFADFSFDGHSAGDDGHGSDlsjflkasjdfksdjflksjdfasdfasdf\(i)"
        }

        let dispatchQueue = DispatchQueue(label: "test.Insertion")
        let count:UInt = 100;
        let expe = expectation(description: "All insertions are complete")
        for _ in 0..<count {
            dispatchQueue.async {
                self.vwoQueue.enqueue(largeDict)
            }
        }
        dispatchQueue.async(flags: .barrier) {
            XCTAssertEqual(self.vwoQueue.count, count)
            expe.fulfill()
        }
        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Failed \(error)")
            }
        }
    }

}
