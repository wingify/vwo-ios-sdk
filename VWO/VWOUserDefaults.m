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

static NSString * kVariationSelected = @"variationSelected";
static NSString * kCampaignsTracked  = @"campaignsTracked";
static NSString * kCampaingsExcluded = @"campaingsExcluded";
static NSString * kGoalsMarked       = @"goalsMarked";
static NSString * kSessionCount      = @"sessionCount";
static NSString * kReturningUser     = @"returningUser";
static NSString * kUUID              = @"UUID";

static NSString * _userDefaultsKey;
NSString *const kOLDUserDefaultsKey = @"vwo.09cde70ba7a94aff9d843b1b846a79a7";

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
    // If old key is present then run the migration.
    if ([NSUserDefaults.standardUserDefaults objectForKey:kOLDUserDefaultsKey] != nil) {
        [self runMigration:key];
        return;
    }
    VWOLogDebug(@"Setting default values");
    NSString *UUID = [NSUUID.UUID.UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSDictionary *defaults = @{
                               kVariationSelected: @[],//Array<NSString> of "CampaignId:VariationID"
                               kCampaignsTracked : @[],//Array<NSNumber> of Campaing Id
                               kCampaingsExcluded: @[],
                               kGoalsMarked      : @[],//Array<NSString> of "CampaignId:GoalID"
                               kSessionCount     : @(0),
                               kReturningUser    : @(NO),
                               kUUID             : UUID
                               };

    [NSUserDefaults.standardUserDefaults setObject:defaults forKey:key];
    VWOLogDebug(@"UUID %@", UUID);
}

/// Runs migration from old format to new format
+ (void)runMigration:(NSString *)newKey {
    VWOLogDebug(@"Running migration from old values to new");
    NSDictionary *oldValues = [NSUserDefaults.standardUserDefaults objectForKey:kOLDUserDefaultsKey];
    NSMutableArray <NSNumber *> *campaignsTracked  = [NSMutableArray new];
    NSMutableArray <NSNumber *> *campaignsExcluded = [NSMutableArray new];
    NSMutableArray <NSString *> *variationSelected = [NSMutableArray new];
    NSDictionary *oldTrackingInfo = oldValues[@"tracking"];
    for (NSString *campaignID in oldTrackingInfo) {
        NSNumber *variationID = oldTrackingInfo[campaignID];
        if (variationID.intValue == 0) {
            [campaignsExcluded addObject:@([campaignID intValue])];
        } else {
            [campaignsTracked addObject:@([campaignID intValue])];
        }
        NSString *campVar = [NSString stringWithFormat:@"%@:%@", campaignID, variationID];
        [variationSelected addObject:campVar];
    }
    NSDictionary *defaults = @{
                               kVariationSelected: variationSelected,
                               kCampaignsTracked : campaignsTracked,
                               kCampaignsTracked : campaignsExcluded,
                               kGoalsMarked      : oldValues[@"goalsMarked"],
                               kSessionCount     : @([oldValues[@"sessionCount"] integerValue]),
                               kReturningUser    : @([oldValues[@"returningUser"] boolValue]),
                               kUUID             : oldValues[@"UUID"]
                               };
    [NSUserDefaults.standardUserDefaults setObject:defaults forKey:newKey];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:kOLDUserDefaultsKey];
}

+ (void)setSelectedVariation:(VWOVariation *)variation for:(VWOCampaign *)campaign {
    NSMutableSet *set = [NSMutableSet setWithArray:(NSArray *)[self objectForKey:kVariationSelected]];
    [set addObject:[NSString stringWithFormat:@"%d:%d", campaign.iD, variation.iD]];
    [self setObject:set.allObjects forKey:kVariationSelected];
}

+ (nullable NSNumber *)selectedVariationForCampaign:(VWOCampaign *)campaign {
    NSArray *variationSelectedList = [self objectForKey:kVariationSelected];
    for (NSString *pair in variationSelectedList) {
        NSString *a = [pair componentsSeparatedByString:@":"][0];
        NSString *b = [pair componentsSeparatedByString:@":"][1];
        if (campaign.iD == [a intValue]) {
            return @([b intValue]);
        }
    }
    return nil;
}

+ (void)trackUserForCampaign:(VWOCampaign *)campaign {
    NSMutableSet *set = [NSMutableSet setWithArray:(NSArray *)[self objectForKey:kCampaignsTracked]];
    [set addObject:@(campaign.iD)];
    [self setObject:set.allObjects forKey:kCampaignsTracked];
}

+ (BOOL)isUserTrackedForCampaign:(VWOCampaign *)campaign {
    NSSet *set = [NSSet setWithArray:(NSArray *)[self objectForKey:kCampaignsTracked]];
    return [set containsObject:@(campaign.iD)];
}

+ (void)setCampaignExcluded:(VWOCampaign *)campaign {
    NSMutableSet *set = [NSMutableSet setWithArray:(NSArray *)[self objectForKey:kCampaingsExcluded]];
    [set addObject:@(campaign.iD)];
    [self setObject:set.allObjects forKey:kCampaingsExcluded];
}

+ (BOOL)isCampaignExcluded:(VWOCampaign *)campaign {
    NSSet *set = [NSSet setWithArray:(NSArray *)[self objectForKey:kCampaingsExcluded]];
    return [set containsObject:@(campaign.iD)];
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

+ (NSString *)UUID {
    return [self objectForKey:kUUID];
}

+ (void)setSessionCount:(NSUInteger)count {
    [self setObject:@(count) forKey:kSessionCount];
    [self updateIsReturningUser];
}

+ (void)updateIsReturningUser {
    NSArray *trackedCampaigns = [self objectForKey:kCampaignsTracked];
    if (trackedCampaigns.count > 0 && self.sessionCount > 1 && self.isReturningUser == NO) {
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
