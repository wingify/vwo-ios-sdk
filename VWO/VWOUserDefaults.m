//
//  VWOUserDefaults.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 06/10/17.
//  Copyright © 2017-2022 vwo. All rights reserved.
//

#import "VWOUserDefaults.h"
#import "VWOCampaign.h"
#import "VWOLogger.h"

static NSString * kTracking                  = @"tracking";
static NSString * kGoalsMarked               = @"goalsMarked";
static NSString * kSessionCount              = @"sessionCount";
static NSString * kReturningUser             = @"returningUser";
static NSString * kUUID                      = @"UUID";
static NSString * kCollectionPrefix          = @"collectionPrefix";
static NSString * kIsEventArchEnabled        = @"isEventArchEnabled";
static NSString * kEventArchData             = @"eventArchData";
static NSString * kNonEventArchData          = @"nonEventArchData";
static NSString * kNetworkHTTPMethodTypeData = @"networkHTTPMethodTypeData";

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

+ (NSString *)CollectionPrefix {
    return [self objectForKey:kCollectionPrefix];
}

+ (NSString *)IsEventArchEnabled {
    return [self objectForKey:kIsEventArchEnabled];
}

+ (NSMutableDictionary *)EventArchData {
    return [self objectForKey:kEventArchData];
}

+ (NSMutableDictionary *)NonEventArchData {
    return [self objectForKey:kNonEventArchData];
}

+ (NSMutableDictionary *)NetworkHTTPMethodTypeData {
    return [self objectForKey:kNetworkHTTPMethodTypeData];
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

+ (void)updateUUID:(NSString *)uuid {
    [self setObject:uuid forKey:kUUID];
}

+ (void)updateCollectionPrefix:(NSString *)collectionPrefix {
    [self setObject:collectionPrefix forKey:kCollectionPrefix];
}

+ (void)updateIsEventArchEnabled:(NSString *)isEventArchEnabled {
    [self setObject:isEventArchEnabled forKey:kIsEventArchEnabled];
}

+ (void)updateEventArchData:(NSString *)url valueDict:(NSMutableDictionary *)EventArchDict {
    NSMutableDictionary *EventArchData = [[self objectForKey:kEventArchData] mutableCopy];
    if(EventArchData == nil){
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        newDict[url] = EventArchDict;
        [self setObject:newDict forKey:kEventArchData];
    }
    else{
        EventArchData[url] = EventArchDict;
        [self setObject:EventArchData forKey:kEventArchData];
    }
}

+ (void)updateNonEventArchData:(NSString *)url valueDict:(NSMutableDictionary *)NonEventArchDict {
    NSMutableDictionary *NonEventArchData = [[self objectForKey:kNonEventArchData] mutableCopy];
    if(NonEventArchData == nil){
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        tempDict[url] = NonEventArchDict;
        [self setObject:tempDict forKey:kNonEventArchData];
    }
    else{
        NonEventArchData[url] = NonEventArchDict;
        [self setObject:NonEventArchData forKey:kNonEventArchData];
    }
}

+(void)updateNetworkHTTPMethodTypeData:(NSString *)url HTTPMethodType:(NSString *)HTTPMethodType {
    NSMutableDictionary *SavedNetworkHTTPMethodTypeData = [[self objectForKey:kNetworkHTTPMethodTypeData] mutableCopy];
    if(SavedNetworkHTTPMethodTypeData == nil){
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        newDict[url] = HTTPMethodType;
        [self setObject:newDict forKey:kNetworkHTTPMethodTypeData];
    }
    else{
        SavedNetworkHTTPMethodTypeData[url] = HTTPMethodType;
        [self setObject:SavedNetworkHTTPMethodTypeData forKey:kNetworkHTTPMethodTypeData];
    }
}

+ (void)removeEventArchDataItem:(NSString *)url {
    NSMutableDictionary *EventArchData = [[self objectForKey:kEventArchData] mutableCopy];
    if(EventArchData != NULL){
        [EventArchData removeObjectForKey:url];
        [self setObject:EventArchData forKey:kEventArchData];
    }
}

+ (void)removeNonEventArchDataItem:(NSString *)url {
    NSMutableDictionary *NonEventArchData = [[self objectForKey:kNonEventArchData] mutableCopy];
    if(NonEventArchData != NULL){
        [NonEventArchData removeObjectForKey:url];
        [self setObject:NonEventArchData forKey:kNonEventArchData];
    }
}

+ (void)removeNetworkHTTPMethodTypeDataItem:(NSString *)url {
    NSMutableDictionary *SavedNetworkHTTPMethodTypeData = [[self objectForKey:kNetworkHTTPMethodTypeData] mutableCopy];
    if(SavedNetworkHTTPMethodTypeData != NULL){
        [SavedNetworkHTTPMethodTypeData removeObjectForKey:url];
        [self setObject:SavedNetworkHTTPMethodTypeData forKey:kNetworkHTTPMethodTypeData];
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
