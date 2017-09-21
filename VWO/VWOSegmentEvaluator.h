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

@property NSMutableDictionary<NSString *, NSString *> *customVariables;

- (BOOL)canUserBePartOfCampaignForSegment:(NSDictionary *) segment;

@end

NS_ASSUME_NONNULL_END
