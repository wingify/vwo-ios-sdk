//
//  VWOActivity.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 09/07/17.
//
//

#import "VWOActivity.h"
#import "VWOCampaign.h"

static NSString * kTracking        = @"tracking";
static NSString * kGoalsMarked     = @"goalsMarked";
static NSString * kSessionCount    = @"sessionCount";
static NSString * kReturningUser   = @"returningUser";
static NSString * kUUID            = @"UUID";
static NSString * kUserDefaultsKey = @"vwo.09cde70ba7a94aff9d843b1b846a79a7";

@implementation VWOActivity

+ (BOOL)isTrackingUserForCampaign:(VWOCampaign *)campaign {
    NSDictionary *activityDict = [NSUserDefaults.standardUserDefaults objectForKey:kUserDefaultsKey];
    NSDictionary *trackingDict = activityDict[kTracking];
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];

    if (trackingDict[campaignID] == nil) {
        return NO;
    }
    return [trackingDict[campaignID] intValue] == campaign.variation.iD;
}

/// Stores "campaignId : "variationID" in User Activity["tracking"]
+ (void)trackUserForCampaign:(VWOCampaign *)campaign {
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];
    int variationID = campaign.status == CampaignStatusExcluded ? 0 : campaign.variation.iD;
    NSMutableDictionary *activityDict = [[NSUserDefaults.standardUserDefaults objectForKey:kUserDefaultsKey] mutableCopy];
    NSMutableDictionary *trackingDict = [activityDict[kTracking] mutableCopy];
    trackingDict[campaignID] = [NSNumber numberWithInt:variationID];
    activityDict[kTracking] = trackingDict;
    [NSUserDefaults.standardUserDefaults setObject:activityDict forKey:kUserDefaultsKey];
}

+ (NSDictionary *)campaignVariationPairs {
    NSDictionary *activityDict = [NSUserDefaults.standardUserDefaults objectForKey:kUserDefaultsKey];
    return activityDict[kTracking];
}

/// Stores "campaignID : goalID" in User Activity["goalsMarked"]
+ (void)markGoalConversion:(VWOGoal *)goal forCampaign:(VWOCampaign *)campaign {
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];
    NSNumber *goalID = [NSNumber numberWithInt:goal.iD];
    NSMutableDictionary *activityDict = [[NSUserDefaults.standardUserDefaults objectForKey:kUserDefaultsKey] mutableCopy];
    activityDict[kGoalsMarked][campaignID] = goalID;
    [NSUserDefaults.standardUserDefaults setObject:activityDict forKey:kUserDefaultsKey];
}

+ (void)markGoalConversion:(VWOGoal *)goal {
    NSMutableDictionary *activityDict = [[NSUserDefaults.standardUserDefaults objectForKey:kUserDefaultsKey] mutableCopy];
    NSMutableSet *set = [NSMutableSet setWithArray:(NSArray *)activityDict[kGoalsMarked]];
    [set addObject:[NSNumber numberWithInt:goal.iD]];
    activityDict[kGoalsMarked] = set.allObjects;
    [NSUserDefaults.standardUserDefaults setObject:activityDict forKey:kUserDefaultsKey];
}

+ (BOOL)isGoalMarked:(VWOGoal *)goal {
    NSDictionary *activityDict = [NSUserDefaults.standardUserDefaults objectForKey:kUserDefaultsKey];
    NSMutableSet *set = [NSMutableSet setWithArray:(NSArray *)activityDict[kGoalsMarked]];
    return [set containsObject:[NSNumber numberWithInt:goal.iD]];
}

+ (void)setSessionCount:(NSUInteger)count {
    NSMutableDictionary *activityDict = [[NSUserDefaults.standardUserDefaults objectForKey:kUserDefaultsKey] mutableCopy];
    activityDict[kSessionCount] = [NSNumber numberWithUnsignedInteger:count];
    [NSUserDefaults.standardUserDefaults setObject:activityDict forKey:kUserDefaultsKey];
}

+ (NSUInteger)sessionCount {
    NSDictionary *activityDict = [NSUserDefaults.standardUserDefaults objectForKey:kUserDefaultsKey];
    return [activityDict[kSessionCount] integerValue];
}

+ (void)setReturningUser:(BOOL)isReturning {
    NSMutableDictionary *activityDict = [[NSUserDefaults.standardUserDefaults objectForKey:kUserDefaultsKey] mutableCopy];
    activityDict[kReturningUser] = [NSNumber numberWithBool:isReturning];
    [NSUserDefaults.standardUserDefaults setObject:activityDict forKey:kUserDefaultsKey];
}

+ (BOOL)isReturningUser {
    NSDictionary *activityDict = [NSUserDefaults.standardUserDefaults objectForKey:kUserDefaultsKey];
    return [activityDict[kReturningUser] boolValue];
}

+ (NSString *)UUID {
    NSDictionary *activityDict = [NSUserDefaults.standardUserDefaults objectForKey:kUserDefaultsKey];
    return activityDict[kUUID];
}

+ (void)setDefaultValues {
    NSString *UUID = [NSUUID.UUID.UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSDictionary *defaults = @{
                               kTracking :  @{},
                               kGoalsMarked :  @[],
                               kSessionCount :  @(0),
                               kReturningUser :  @(NO),
                               kUUID : UUID
                               };
    [NSUserDefaults.standardUserDefaults registerDefaults:@{kUserDefaultsKey : defaults}];
}

@end
