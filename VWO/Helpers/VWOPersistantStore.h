//
//  VWOPersistantStore.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 09/07/17.
//
//

#import <Foundation/Foundation.h>

@class VWOCampaign, VWOGoal;

NS_ASSUME_NONNULL_BEGIN

@interface VWOPersistantStore : NSObject

@property (class, readonly) NSDictionary *campaignVariationPairs;
@property (class, assign) NSUInteger sessionCount;
@property (class, assign, getter=isReturningUser) BOOL returningUser;
@property (class, readonly) NSString *UUID;

+ (BOOL)isTrackingUserForCampaign:(VWOCampaign *)campaign;
+ (void)trackUserForCampaign:(VWOCampaign *)campaign;

+ (void)markGoalConversion:(VWOGoal *)goal;
+ (BOOL)isGoalMarked:(VWOGoal *)goal;

@end
NS_ASSUME_NONNULL_END
