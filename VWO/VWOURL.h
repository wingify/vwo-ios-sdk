//
//  VWOURL.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 15/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VWOCampaign, VWOGoal;

@interface VWOURL : NSObject

+ (NSURL *)forFetchingCampaigns;
+ (NSURL *)forMakingUserPartOfCampaign:(VWOCampaign *)campaign dateTime:(NSDate *)date;
+ (NSURL *)forMarkingGoal:(VWOCampaign *)campaign goal:(VWOGoal *)goal dateTime:(NSDate *)date withValue:(NSNumber *)goalValue;

@end

NS_ASSUME_NONNULL_END
