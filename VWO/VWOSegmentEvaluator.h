//
//  VWOSegmentEvaluator.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 30/06/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VWOSegmentEvaluator : NSObject

/// This method will receive content of "segment_object"
+ (BOOL)canUserBePartOfCampaignForSegment:(NSDictionary *) segment customVariables:(NSDictionary *)customVariable;
@end

NS_ASSUME_NONNULL_END
