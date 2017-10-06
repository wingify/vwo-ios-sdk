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

+ (NSURL *)forFetchingCampaignsAccountID:(NSString *)accountID
                                  appKey:(NSString *)appKey
                              sdkVersion:(NSString *)sdkVersion;

+ (NSURL *)forMakingUserPartOfCampaign:(VWOCampaign *)campaign
                             accountID:(NSString *)accountID
                                appKey:(NSString *)appKey
                              dateTime:(NSDate *)date
                            sdkVersion:(NSString *)sdkVersion;

+ (NSURL *)forMarkingGoal:(VWOGoal *)goal
                withValue:(NSNumber *)goalValue
                 campaign:(VWOCampaign *)campaign
                 dateTime:(NSDate *)date
                accountID:(NSString *)accountID
                   appKey:(NSString *)appKey
               sdkVersion:(NSString *)sdkVersion;

@end

NS_ASSUME_NONNULL_END
