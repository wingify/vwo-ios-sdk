//
//  BasicSegmentation.swift
//  VWOTests
//
//  Created by Kaunteya Suryawanshi on 12/03/18.
//  Copyright © 2018 vwo. All rights reserved.
//

import XCTest

class BasicSegmentation: XCTestCase {
    func testSegmentObjectNil() {
        //Segment object is nil when user does not enable segmentation
        let evaluator = VWOSegmentEvaluator()
        evaluator.appleDeviceType = .iPhone
        XCTAssert(evaluator.canUserBePartOfCampaign(forSegment: nil))
    }
}
