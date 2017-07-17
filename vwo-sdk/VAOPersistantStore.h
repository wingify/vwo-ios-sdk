//
//  VAOPersistantStore.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 09/07/17.
//
//

#import <Foundation/Foundation.h>
#import "VAOCampaign.h"

NS_ASSUME_NONNULL_BEGIN
@interface VAOPersistantStore : NSObject

+ (BOOL)isTrackingUserForCampaign:(VAOCampaign *)campaign;
+ (void)trackUserForCampaign:(VAOCampaign *)campaign;

+ (NSDictionary *)campaignVariationPairs;

+ (void)markGoalConversion:(VAOGoal *)goal;
+ (BOOL)isGoalMarked:(VAOGoal *)goal;

+ (NSUInteger)sessionCount;
+ (void)incrementSessionCount;

+ (void)setReturningUser:(BOOL)isReturning;
+ (BOOL)returningUser;

+ (NSString *)UUID;

+ (void)log;

@end
NS_ASSUME_NONNULL_END
