//
//  VWOSegmentEvaluator.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 30/06/17.
//
//

#import <Foundation/Foundation.h>
#import "VWODevice.h"
#import "VWOSegment.h"

NS_ASSUME_NONNULL_BEGIN

@interface VWOSegmentEvaluator : NSObject

@property NSDictionary<NSString *, NSString *> *customVariables;
@property VWOAppleDeviceType appleDeviceType;
@property BOOL isReturning;
@property NSDate *date;//for hour of the day and day of Week
@property NSString *appVersion;
@property NSString *iOSVersion;
@property NSLocale *locale;
@property uint screenWidth;
@property uint screenHeight;

- (BOOL)canUserBePartOfCampaignForSegment:(nullable NSDictionary *)segment;
- (BOOL)evaluate:(VWOSegment *) segment;

+ (VWOSegmentEvaluator *)makeEvaluator:(NSDictionary<NSString *, NSString *> *)customVariables;
@end

NS_ASSUME_NONNULL_END
