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

    // TODO: Move this to VWOURL, as it is specific to it
//@property (class, readonly) NSDictionary *campaignVariationPairs;
@property (class) NSUInteger sessionCount;

// Returning user will be set  when session count is updated
@property (class, getter=isReturningUser, readonly) BOOL returningUser;
@property (class, readonly) NSString *UUID;

// To determine which variation is selected for given campaign
//+ (void)setSelectedVariationID:(int)variationID forCampaignID:(int)campaignID;
+ (void)setSelectedVariationFor:(VWOCampaign *)campaign;
+ (nullable NSNumber *)selectedVariationForCampaignID:(int)campaignID;

// /track-user has been sent for this campaign-variation
+ (void)trackUserForCampaign:(VWOCampaign *)campaign;
+ (BOOL)isUserTrackedForCampaign:(VWOCampaign *)campaign;

// List of all the campaigns that have been excluded
+ (void)setCampaignExcluded:(VWOCampaign *)campaign;
+ (BOOL)isCampaignExcluded:(VWOCampaign *)campaign;

// /track-goal has been called for this user
+ (void)markGoalConversion:(VWOGoal *)goal inCampaign:(VWOCampaign *)campaign;
+ (BOOL)isGoalMarked:(VWOGoal *)goal inCampaign:(VWOCampaign *)campaign;

+ (void)setDefaultsKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
