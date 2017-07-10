//
//  VWOSegmentEvaluator.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 30/06/17.
//
//

#import <Foundation/Foundation.h>

@interface VWOSegmentEvaluator : NSObject

/// This method will receive content of "segment_object"
+ (BOOL)canUserBePartOfCampaignForSegment:(NSDictionary *) segment;

@end
