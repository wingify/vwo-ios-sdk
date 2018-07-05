//
//  VWOUserDefaults.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 06/10/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class  VWOCampaign, VWOGoal;

@interface VWOUserDefaults : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (class, readonly) NSDictionary *campaignVariationPairs;
@property (class) NSUInteger sessionCount;

// Returning user will be set  when session count is updated
@property (class, getter=isReturningUser, readonly) BOOL returningUser;
@property (class, readonly) NSString *UUID;

+ (void)setExcludedCampaign:(VWOCampaign *)campaign;

+ (BOOL)isTrackingUserForCampaign:(VWOCampaign *)campaign;
+ (void)trackUserForCampaign:(VWOCampaign *)campaign;

+ (void)markGoalConversion:(VWOGoal *)goal inCampaign:(VWOCampaign *)campaign;
+ (BOOL)isGoalMarked:(VWOGoal *)goal inCampaign:(VWOCampaign *)campaign;

+ (void)setDefaultsKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
