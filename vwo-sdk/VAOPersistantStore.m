//
//  VAOPersistantStore.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 09/07/17.
//
//

#import "VAOPersistantStore.h"

static NSString * kTracking = @"tracking";
static NSString * kGoalsMarked = @"goalsMarked";
static NSString * kSessionCount = @"sessionCount";
static NSString * kReturningUser = @"returningUser";

@implementation VAOPersistantStore

+ (BOOL)isTrackingUserForCampaign:(VAOCampaign *)campaign {
    NSDictionary *userDict = [self dictionary];
    NSDictionary *trackingDict = userDict[kTracking];
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];

    if (trackingDict[campaignID] == nil) {
        return NO;
    }
    return [trackingDict[campaignID] intValue] == campaign.variation.id;
}

/// Stores "campaignId : "variationID" in User Activity["tracking"]
+ (void)trackUserForCampaign:(VAOCampaign *)campaign {
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];
    NSNumber *variationID = [NSNumber numberWithInt:campaign.variation.id];
    NSMutableDictionary *userDict = [self dictionary];
    userDict[kTracking][campaignID] = variationID;
    [userDict writeToFile:[self filePath] atomically:YES];
}

+ (NSDictionary *)campaignVariationPairs {
    NSDictionary *userDict = [self dictionary];
    return userDict[kTracking];
}

/// Stores "campaignID : goalID" in User Activity["goalsMarked"]
+ (void)markGoalConversion:(VAOGoal *)goal forCampaign:(VAOCampaign *)campaign {
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];
    NSNumber *goalID = [NSNumber numberWithInt:goal.id];
    NSMutableDictionary *userDict = [self dictionary];
    userDict[kGoalsMarked][campaignID] = goalID;
    [self writeToFile:userDict];
}

+ (void)markGoalConversion:(VAOGoal *)goal {
    NSMutableDictionary *userDict = [self dictionary];
    NSMutableSet *set = [NSMutableSet setWithArray:(NSArray *)userDict[kGoalsMarked]];
    [set addObject:[NSNumber numberWithInt:goal.id]];
    userDict[kGoalsMarked] = [set allObjects];
    [self writeToFile:userDict];
}

+ (BOOL)isGoalMarked:(VAOGoal *)goal {
    NSMutableDictionary *userDict = [self dictionary];
    NSMutableSet *set = [NSMutableSet setWithArray:(NSArray *)userDict[kGoalsMarked]];
    return [set containsObject:[NSNumber numberWithInt:goal.id]];
}

+ (void)incrementSessionCount {
    NSMutableDictionary *userDict = [self dictionary];
    userDict[kSessionCount] = @([userDict[kSessionCount] longValue] + 1);
    [self writeToFile:userDict];
}

+ (NSUInteger)sessionCount {
    NSMutableDictionary *userDict = [self dictionary];
    return [userDict[kSessionCount] integerValue];
}

+ (void)setReturningUser:(BOOL)isReturning {
    NSMutableDictionary *userDict = [self dictionary];
    userDict[kReturningUser] = @(isReturning);
    [self writeToFile:userDict];
}

+ (BOOL)returningUser {
    NSMutableDictionary *userDict = [self dictionary];
    return [userDict[kReturningUser] boolValue];
}

#pragma mark - Core
//[self filePath] must not appear above this

/// All publicly exposed methods must access PersistantStore only this this dictionary
+ (NSMutableDictionary *)dictionary {
    [self createFile];//Exists if already exists
    return [NSMutableDictionary dictionaryWithContentsOfFile:[self filePath]];
}

+ (void)writeToFile:(NSDictionary *) dict{
    [dict writeToFile:[self filePath] atomically:YES];
}

+ (NSString *)filePath  {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/VWOActivity.plist"];
}

+ (void)createFile {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self filePath]]) {
        return;
    }
    NSMutableDictionary *activityDict = [NSMutableDictionary new];
    activityDict[kTracking] = @{};
    activityDict[kGoalsMarked] = @[];
    activityDict[kSessionCount] = @(0);
    activityDict[kReturningUser] = @(NO);
    [self writeToFile:activityDict];
}

+ (void)log {
    NSLog(@"USER ACTIVITY %@", [self dictionary]);
}

@end
