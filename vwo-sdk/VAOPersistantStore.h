//
//  VAOPersistantStore.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 09/07/17.
//
//

#import <Foundation/Foundation.h>

@class VAOCampaign, VAOGoal;

NS_ASSUME_NONNULL_BEGIN

@interface VAOPersistantStore : NSObject

@property (class, readonly) NSDictionary *campaignVariationPairs;
@property (class, assign) NSUInteger sessionCount;
@property (class, assign, getter=isReturningUser) BOOL returningUser;
@property (class, readonly) NSString *UUID;

+ (BOOL)isTrackingUserForCampaign:(VAOCampaign *)campaign;
+ (void)trackUserForCampaign:(VAOCampaign *)campaign;

+ (void)markGoalConversion:(VAOGoal *)goal;
+ (BOOL)isGoalMarked:(VAOGoal *)goal;

@end
NS_ASSUME_NONNULL_END
