//
//  VWOUserDefaults.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 06/10/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "VWOUserDefaults.h"
#import "VWOCampaign.h"
#import "VWOLogger.h"

static NSString * kTracking        = @"tracking";
static NSString * kGoalsMarked     = @"goalsMarked";
static NSString * kSessionCount    = @"sessionCount";
static NSString * kReturningUser   = @"returningUser";
static NSString * kUUID            = @"UUID";

static NSString * _userDefaultsKey;

@implementation VWOUserDefaults

+ (nullable id)objectForKey:(NSString *)key {
    NSDictionary *activityDict = [NSUserDefaults.standardUserDefaults objectForKey:_userDefaultsKey];
    return activityDict[key];
}

+ (void)setObject:(nullable id)value forKey:(NSString *)key {
    NSParameterAssert(_userDefaultsKey != nil);
    NSMutableDictionary *activityDict = [[NSUserDefaults.standardUserDefaults
                                          objectForKey:_userDefaultsKey] mutableCopy];
    activityDict[key] = value;
    [NSUserDefaults.standardUserDefaults setObject:activityDict forKey:_userDefaultsKey];
}

+ (void)setDefaultsKey:(NSString *)key {
    _userDefaultsKey = key;
    if ([NSUserDefaults.standardUserDefaults objectForKey:key] != nil) {
        return;
    }
    VWOLogDebug(@"Setting default values for first launch");
    NSString *UUID = [NSUUID.UUID.UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSDictionary *defaults = @{
                               kTracking     : @{},
                               kGoalsMarked  : @[],
                               kSessionCount : @(0),
                               kReturningUser: @(NO),
                               kUUID         : UUID
                               };
    [NSUserDefaults.standardUserDefaults setObject:defaults forKey:key];
    VWOLogDebug(@"UUID %@", UUID);
}

+ (BOOL)isTrackingUserForCampaign:(VWOCampaign *)campaign {
    NSDictionary *trackingDict = [self objectForKey:kTracking];
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];

    if (trackingDict[campaignID] == nil) { return NO; }
    return [trackingDict[campaignID] intValue] == campaign.variation.iD;
}

    /// Stores campaignId : 0
+ (void)setExcludedCampaign:(VWOCampaign *)campaign {
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];
    NSMutableDictionary *trackingDict = [[self objectForKey:kTracking] mutableCopy];
    trackingDict[campaignID] = @0;
    [self setObject:trackingDict forKey:kTracking];
}

+ (void)trackUserForCampaign:(VWOCampaign *)campaign {
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];
    NSMutableDictionary *trackingDict = [[self objectForKey:kTracking] mutableCopy];
    trackingDict[campaignID] = @(campaign.variation.iD);
    [self setObject:trackingDict forKey:kTracking];
}

+ (void)markGoalConversion:(VWOGoal *)goal inCampaign:(VWOCampaign *)campaign {
    NSMutableSet *set = [NSMutableSet setWithArray:(NSArray *)[self objectForKey:kGoalsMarked]];
    [set addObject:[NSString stringWithFormat:@"%d:%d", campaign.iD, goal.iD]];
    [self setObject:set.allObjects forKey:kGoalsMarked];
}

+ (BOOL)isGoalMarked:(VWOGoal *)goal inCampaign:(VWOCampaign *)campaign {
    NSMutableSet *set = [NSMutableSet setWithArray:(NSArray *)[self objectForKey:kGoalsMarked]];
    return [set containsObject:[NSString stringWithFormat:@"%d:%d", campaign.iD, goal.iD]];
}

+ (NSDictionary *)campaignVariationPairs {
    return [self objectForKey:kTracking];
}

+ (NSString *)UUID {
    return [self objectForKey:kUUID];
}

+ (void)setSessionCount:(NSUInteger)count {
    [self setObject:@(count) forKey:kSessionCount];
    [self updateIsReturningUser];
}

+ (void)updateIsReturningUser {
    NSDictionary *trackingDict = [self objectForKey:kTracking];
    if (trackingDict.count > 0 && self.sessionCount > 1 && self.isReturningUser == NO) {
        VWOLogDebug(@"Setting returningUser=YES");
        self.returningUser = YES;
    }
}

+ (NSUInteger)sessionCount {
    return [[self objectForKey:kSessionCount] integerValue];
}

+ (void)setReturningUser:(BOOL)isReturning {
    [self setObject:@(isReturning) forKey:kReturningUser];
}

+ (BOOL)isReturningUser {
    return [[self objectForKey:kReturningUser] boolValue];
}

@end
