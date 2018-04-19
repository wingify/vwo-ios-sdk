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

+ (instancetype)urlWithAppKey:(NSString *)appKey accountID:(NSString *)accountID;

- (NSURL *)forFetchingCampaigns;

- (NSURL *)forMakingUserPartOfCampaign:(VWOCampaign *)campaign
                              date:(NSDate *)date;

- (NSURL *)forMarkingGoal:(VWOGoal *)goal
                withValue:(nullable NSNumber *)goalValue
                 campaign:(VWOCampaign *)campaign
                 date:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
