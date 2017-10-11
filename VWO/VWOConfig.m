//
//  VWOConfig.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 06/10/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "VWOConfig.h"
#import "VWOCampaign.h"
#import "VWOLogger.h"

static NSString * kTracking        = @"tracking";
static NSString * kGoalsMarked     = @"goalsMarked";
static NSString * kSessionCount    = @"sessionCount";
static NSString * kReturningUser   = @"returningUser";
static NSString * kUUID            = @"UUID";
static NSString * kUserDefaultsKey = @"vwo.09cde70ba7a94aff9d843b1b846a79a7";

@implementation VWOConfig

- (instancetype)initWithAccountID:(NSString *)accountID
                           appKey:(NSString *)appKey
                       sdkVersion:(NSString *)sdkVersion {
    if (self = [super init]) {
        [self setDefaultValues];
        _accountID  = accountID;
        _appKey     = appKey;
        _sdkVersion = sdkVersion;
    }
    return self;
}

- (nullable id)objectForKey:(NSString *)key {
    NSDictionary *activityDict = [NSUserDefaults.standardUserDefaults objectForKey:kUserDefaultsKey];
    return activityDict[key];
}

- (void)setObject:(nullable id)value forKey:(NSString *)key {
    NSMutableDictionary *activityDict = [[NSUserDefaults.standardUserDefaults objectForKey:kUserDefaultsKey] mutableCopy];
    activityDict[key] = value;
    [NSUserDefaults.standardUserDefaults setObject:activityDict forKey:kUserDefaultsKey];
}

- (void)setDefaultValues {
    if ([NSUserDefaults.standardUserDefaults objectForKey:kUserDefaultsKey] != nil) {
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
//    [NSUserDefaults.standardUserDefaults setObject:defaults forKey:kUserDefaultsKey];
    [NSUserDefaults.standardUserDefaults registerDefaults:@{kUserDefaultsKey : defaults}];
    VWOLogDebug(@"UUID %@", UUID);
}

- (BOOL)isTrackingUserForCampaign:(VWOCampaign *)campaign {
    NSDictionary *trackingDict = [self objectForKey:kTracking];
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];

    if (trackingDict[campaignID] == nil) return NO;
    return [trackingDict[campaignID] intValue] == campaign.variation.iD;
}

    /// Stores "campaignId : "variationID" in User Activity["tracking"]
- (void)trackUserForCampaign:(VWOCampaign *)campaign {
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];
    int variationID = campaign.status == CampaignStatusExcluded ? 0 : campaign.variation.iD;

    NSMutableDictionary *trackingDict = [[self objectForKey:kTracking] mutableCopy];
    trackingDict[campaignID] = [NSNumber numberWithInt:variationID];
    [self setObject:trackingDict forKey:kTracking];
}

- (void)markGoalConversion:(VWOGoal *)goal {
    NSMutableSet *set = [NSMutableSet setWithArray:(NSArray *)[self objectForKey:kGoalsMarked]];
    [set addObject:[NSNumber numberWithInt:goal.iD]];
    [self setObject:set.allObjects forKey:kGoalsMarked];
}

- (BOOL)isGoalMarked:(VWOGoal *)goal {
    NSMutableSet *set = [NSMutableSet setWithArray:(NSArray *)[self objectForKey:kGoalsMarked]];
    return [set containsObject:[NSNumber numberWithInt:goal.iD]];
}


- (NSDictionary *)campaignVariationPairs {
    return [self objectForKey:kTracking];
}

- (NSString *)UUID {
    return [self objectForKey:kUUID];
}

- (void)setSessionCount:(NSUInteger)count {
    [self setObject:@(count) forKey:kSessionCount];
    [self updateIsReturningUser];
}

- (void)updateIsReturningUser {
    NSDictionary *trackingDict = [self objectForKey:kTracking];
    if (trackingDict.count > 0 && self.sessionCount > 1 && self.isReturningUser == NO) {
        VWOLogDebug(@"Setting returningUser=YES");
        self.returningUser = YES;
    }
}

- (NSUInteger)sessionCount {
    return [[self objectForKey:kSessionCount] integerValue];
}

- (void)setReturningUser:(BOOL)isReturning {
    [self setObject:@(isReturning) forKey:kReturningUser];
}

- (BOOL)isReturningUser {
    return [[self objectForKey:kReturningUser] boolValue];
}

@end
