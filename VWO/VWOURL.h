//
//  VWOURL.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 15/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VWOCampaign, VWOGoal, VWOUserDefaults;

@interface VWOURL : NSObject

+ (NSURL *)forFetchingCampaignsConfig:(VWOUserDefaults *)config;

+ (NSURL *)forMakingUserPartOfCampaign:(VWOCampaign *)campaign
                                config:(VWOUserDefaults *)config
                              dateTime:(NSDate *)date;

+ (NSURL *)forMarkingGoal:(VWOGoal *)goal
                withValue:(nullable NSNumber *)goalValue
                 campaign:(VWOCampaign *)campaign
                 dateTime:(NSDate *)date
                   config:(VWOUserDefaults *)config;

@end

NS_ASSUME_NONNULL_END
