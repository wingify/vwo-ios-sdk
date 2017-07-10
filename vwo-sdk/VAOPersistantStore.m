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

@implementation VAOPersistantStore

+ (BOOL)isTrackingUserForCampaign:(VAOCampaign *)campaign {
    NSMutableDictionary *userDict = [self dictionary];
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];
    return (userDict[kTracking][campaignID] != nil &&
            [userDict[kTracking][campaignID] intValue] == campaign.variation.id);
}

/// Stores "campaignId : "variationID" in User Activity["tracking"]
+ (void)trackUserForCampaign:(VAOCampaign *)campaign {
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];
    NSNumber *variationID = [NSNumber numberWithInt:campaign.variation.id];
    NSMutableDictionary *userDict = [self dictionary];
    userDict[kTracking][campaignID] = variationID;
    [userDict writeToFile:[self filePath] atomically:YES];
}

/// Stores "campaignID : goalID" in User Activity["goalsMarked"]
+ (void)markGoalConversion:(VAOGoal *)goal forCampaign:(VAOCampaign *)campaign {
    NSString *campaignID = [NSString stringWithFormat:@"%d", campaign.iD];
    NSNumber *goalID = [NSNumber numberWithInt:goal.id];
    NSMutableDictionary *userDict = [self dictionary];
    userDict[kGoalsMarked][campaignID] = goalID;
    [userDict writeToFile:[self filePath] atomically:YES];
}

+ (void)markGoalConversion:(VAOGoal *)goal {
    NSMutableDictionary *userDict = [self dictionary];
    NSMutableSet *set = [NSMutableSet setWithArray:(NSArray *)userDict[kGoalsMarked]];
    [set addObject:[NSNumber numberWithInt:goal.id]];
    userDict[kGoalsMarked] = [set allObjects];
    [userDict writeToFile:[self filePath] atomically:YES];
}

+ (BOOL)isGoalMarked:(VAOGoal *)goal {
    NSMutableDictionary *userDict = [self dictionary];
    NSMutableSet *set = [NSMutableSet setWithArray:(NSArray *)userDict[kGoalsMarked]];
    return [set containsObject:[NSNumber numberWithInt:goal.id]];
}

+ (NSMutableDictionary *)dictionary {
    [self createFile];//Exists if already exists
    return [NSMutableDictionary dictionaryWithContentsOfFile:[self filePath]];
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
    [activityDict writeToFile:[self filePath] atomically:YES];
}

+ (void)log {
    NSLog(@"USER ACTIVITY %@", [self dictionary]);
}

@end
