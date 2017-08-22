//
//  VAOPersistantStore.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 09/07/17.
//
//

#import "VAOPersistantStore.h"
#import "VAOCampaign.h"
#import "VAOFile.h"

static NSString * kTracking      = @"tracking";
static NSString * kGoalsMarked   = @"goalsMarked";
static NSString * kSessionCount  = @"sessionCount";
static NSString * kReturningUser = @"returningUser";
static NSString * kUUID          = @"UUID";

@implementation VAOPersistantStore

+ (BOOL)isTrackingUserForCampaign:(VAOCampaign *)campaign {
    NSDictionary *userDict = [self dictionary];
    NSDictionary *trackingDict = userDict[kTracking];
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];

    if (trackingDict[campaignID] == nil) {
        return NO;
    }
    return [trackingDict[campaignID] intValue] == campaign.variation.iD;
}

/// Stores "campaignId : "variationID" in User Activity["tracking"]
+ (void)trackUserForCampaign:(VAOCampaign *)campaign {
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];
    NSNumber *variationID = [NSNumber numberWithInt:campaign.variation.iD];
    NSMutableDictionary *userDict = [self dictionary];
    userDict[kTracking][campaignID] = variationID;
    [self writeToFile:userDict];
}

+ (NSDictionary *)campaignVariationPairs {
    NSDictionary *userDict = [self dictionary];
    return userDict[kTracking];
}

/// Stores "campaignID : goalID" in User Activity["goalsMarked"]
+ (void)markGoalConversion:(VAOGoal *)goal forCampaign:(VAOCampaign *)campaign {
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];
    NSNumber *goalID = [NSNumber numberWithInt:goal.iD];
    NSMutableDictionary *userDict = [self dictionary];
    userDict[kGoalsMarked][campaignID] = goalID;
    [self writeToFile:userDict];
}

+ (void)markGoalConversion:(VAOGoal *)goal {
    NSMutableDictionary *userDict = [self dictionary];
    NSMutableSet *set = [NSMutableSet setWithArray:(NSArray *)userDict[kGoalsMarked]];
    [set addObject:[NSNumber numberWithInt:goal.iD]];
    userDict[kGoalsMarked] = [set allObjects];
    [self writeToFile:userDict];
}

+ (BOOL)isGoalMarked:(VAOGoal *)goal {
    NSMutableDictionary *userDict = [self dictionary];
    NSMutableSet *set = [NSMutableSet setWithArray:(NSArray *)userDict[kGoalsMarked]];
    return [set containsObject:[NSNumber numberWithInt:goal.iD]];
}

+ (void)setSessionCount:(NSUInteger)count {
    NSMutableDictionary *userDict = [self dictionary];
    userDict[kSessionCount] = [NSNumber numberWithUnsignedInteger:count];
    [self writeToFile:userDict];
}

+ (NSUInteger)sessionCount {
    NSMutableDictionary *userDict = [self dictionary];
    return [userDict[kSessionCount] integerValue];
}

+ (void)setReturningUser:(BOOL)isReturning {
    NSMutableDictionary *userDict = [self dictionary];
    userDict[kReturningUser] = [NSNumber numberWithBool:isReturning];
    [self writeToFile:userDict];
}

+ (BOOL)isReturningUser {
    NSMutableDictionary *userDict = [self dictionary];
    return [userDict[kReturningUser] boolValue];
}

+ (NSString *)UUID {
    NSMutableDictionary *userDict = [self dictionary];
    return userDict[kUUID];
}

#pragma mark - Core
//[self filePath] must not appear above this

/// All publicly exposed methods must access PersistantStore using this dictionary
+ (NSMutableDictionary *)dictionary {
    [self createFile];//Exists if already exists
    return [NSMutableDictionary dictionaryWithContentsOfURL:VAOFile.activityPath];
}

+ (void)writeToFile:(NSDictionary *) dict{
    [dict writeToURL:VAOFile.activityPath atomically:YES];
}

+ (void)createFile {
    if ([NSFileManager.defaultManager fileExistsAtPath:VAOFile.activityPath.path]) {
        return;
    }
    NSMutableDictionary *activityDict = [NSMutableDictionary new];
    activityDict[kTracking] = @{};
    activityDict[kGoalsMarked] = @[];
    activityDict[kSessionCount] = @(0);
    activityDict[kReturningUser] = @(NO);
    NSString *UUID = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    activityDict[kUUID] = UUID;
    [self writeToFile:activityDict];
}

@end
