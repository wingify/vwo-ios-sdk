//
//  VWOConfig.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 06/10/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class  VWOCampaign, VWOGoal;

@interface VWOConfig : NSObject

@property (readonly) NSString *accountID;
@property (readonly) NSString *appKey;

@property (readonly) NSDictionary *campaignVariationPairs;
@property (assign) NSUInteger sessionCount;
@property (assign, getter=isReturningUser) BOOL returningUser;
@property (readonly) NSString *UUID;


+ (instancetype)configWithAPIKey:(NSString *)apiKey;

- (BOOL)isTrackingUserForCampaign:(VWOCampaign *)campaign;
- (void)trackUserForCampaign:(VWOCampaign *)campaign;

- (void)markGoalConversion:(VWOGoal *)goal inCampaign:(VWOCampaign *)campaign;
- (BOOL)isGoalMarked:(VWOGoal *)goal inCampaign:(VWOCampaign *)campaign;

@end

NS_ASSUME_NONNULL_END
