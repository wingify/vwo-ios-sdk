//
//  VWOURL.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 15/09/17.
//  Copyright © 2017-2022 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VWOCampaign, VWOGoal, VWOUserDefaults, VWOConfig;

@interface VWOURL : NSObject

+ (instancetype)urlWithAppKey:(NSString *)appKey accountID:(NSString *)accountID isChinaCDN:(BOOL)isChinaCDN;

- (NSURL *)forFetchingCampaigns:(nullable NSString *)userID;

- (NSURL *)forMakingUserPartOfCampaign:(VWOCampaign *)campaign
                              dateTime:(NSDate *)date
                              config:(VWOConfig *) config;

- (NSURL *)forMakingUserPartOfCampaignEventArch:(VWOCampaign *)campaign
                              dateTime:(NSDate *)date
                              config:(VWOConfig *) config;

- (NSURL *)forMarkingGoal:(VWOGoal *)goal
                withValue:(nullable NSNumber *)goalValue
                campaign:(VWOCampaign *)campaign
                dateTime:(NSDate *)date;

- (NSURL *)forMarkingGoalEventArch:(VWOGoal *)goal
                withValue:(nullable NSNumber *)goalValue
                campaign:(VWOCampaign *)campaign
                dateTime:(NSDate *)date;

- (NSURL *)forPushingCustomDimension:(NSString *) customDimensionKey
                        withCustomDimensionValue:(NSString *) customDimensionValue
                        dateTime:(NSDate *)date;

- (NSURL *)forPushingCustomDimensionEventArch:(NSString *)customDimensionKey
                                withCustomDimensionValue:(nonnull NSString *)customDimensionValue
                                     dateTime:(nonnull NSDate *)date;

- (NSURL *)forPushingCustomDimension:(NSMutableDictionary *)customDimensionDictionary
                            dateTime:(nonnull NSDate *)date;

- (NSURL *)forPushingCustomDimensionEventArch:(NSMutableDictionary *)customDimensionDictionary
                                     dateTime:(nonnull NSDate *)date;

@end

NS_ASSUME_NONNULL_END
