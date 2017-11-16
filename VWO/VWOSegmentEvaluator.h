//
//  VWOSegmentEvaluator.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 30/06/17.
//
//

#import <Foundation/Foundation.h>
#import "VWODevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface VWOSegmentEvaluator : NSObject

@property NSDictionary<NSString *, NSString *> *customVariables;
@property VWOAppleDeviceType appleDeviceType;
@property BOOL isReturning;
@property NSDate *date;//for hour of the day and day of Week
@property NSString *appVersion;
@property NSString *iOSVersion;

- (instancetype)initWithiOSVersion:(NSString *)iOSVersion
                        appVersion:(NSString *)appVersion
                              date:(NSDate *)date
                       isReturning:(BOOL)isReturning
                     appDeviceType:(VWOAppleDeviceType)deviceType
                   customVariables:(nullable NSDictionary *)customVariables;

- (BOOL)canUserBePartOfCampaignForSegment:(NSDictionary *)segment;

@end

NS_ASSUME_NONNULL_END
