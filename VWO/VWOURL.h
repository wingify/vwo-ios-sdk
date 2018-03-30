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

+ (NSURL *)forFetchingCampaignsAppKey:(NSString *)appKey
                            accountID:(NSString *)accountID;

+ (NSURL *)forMakingUserPartOfCampaign:(VWOCampaign *)campaign
                                appKey:(NSString *)appKey
                             accountID:(NSString *)accountID
                              dateTime:(NSDate *)date;

+ (NSURL *)forMarkingGoal:(VWOGoal *)goal
                withValue:(NSNumber *)goalValue
                 campaign:(VWOCampaign *)campaign
                 dateTime:(NSDate *)date
                   appKey:(NSString *)appKey
                accountID:(NSString *)accountID;

@end

NS_ASSUME_NONNULL_END
