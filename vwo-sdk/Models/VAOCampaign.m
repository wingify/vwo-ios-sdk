//
//  VAOCampaign.m
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import "VAOCampaign.h"
#import "NSDictionary+VWO.h"
#import "VAOLogger.h"

static NSString * kId                   = @"id";
static NSString * kName                 = @"name";
static NSString * kTrackUserOnLaunch    = @"track_user_on_launch";
static NSString * kStatus               = @"status";
static NSString * kSegmentObject        = @"segment_object";
static NSString * kGoals                = @"goals";
static NSString * kVariation            = @"variations";

@implementation VAOCampaign

- (instancetype)initWithID:(int)iD
                      name:(NSString *)name
         trackUserOnLaunch:(BOOL) trackUserOnLaunch
            campaignStatus:(CampaignStatus)campaignStatus
             segmentObject:(nullable NSDictionary *)segmentObject
                     goals:(NSArray<VAOGoal *>*)goals
                 variation:(VAOVariation *)variation {
    NSParameterAssert(name);
    NSParameterAssert(goals);
    NSParameterAssert(variation);
    if (self = [super init]) {
        self.iD                = iD;
        self.name              = name;
        self.trackUserOnLaunch = trackUserOnLaunch;
        self.campaignStatus    = campaignStatus;
        self.segmentObject     = segmentObject;
        self.goals             = goals;
        self.variation         = variation;
    }
    return [self init];
}

- (nullable instancetype)initWithDictionary:(NSDictionary *) campaignDict {
    NSParameterAssert(campaignDict);
    NSArray *mustHaveKeys = @[kId, kName, kTrackUserOnLaunch, kStatus, kGoals, kVariation];
    NSArray *missingKeys  = [campaignDict keysMissingFrom:mustHaveKeys];
    if (missingKeys.count > 0) {
        VAOLogException(@"Keys missing [%@] for Campaign JSON {%@}", [missingKeys componentsJoinedByString:@", "], campaignDict);
        return nil;
    }

    int iD                      = [campaignDict[kId] intValue];
    NSString * name             = campaignDict[kName];
    BOOL trackUserOnLaunch      = [campaignDict[kTrackUserOnLaunch] boolValue];
    NSDictionary *segmentObject = campaignDict[kSegmentObject];

    // Status
    CampaignStatus campaignStatus = CampaignStatusRunning;
    NSString *statusString = campaignDict[kStatus];
    if ([statusString isEqualToString:@"RUNNING"]) {
        campaignStatus = CampaignStatusRunning;
    } else if ([statusString isEqualToString:@"EXCLUED"]) {
        campaignStatus = CampaignStatusExcluded;
    }

    //Goals
    NSMutableArray<VAOGoal *>*goals = [NSMutableArray new];
    NSArray *goalsDict = campaignDict[kGoals];
    for (NSDictionary *goalDict in goalsDict) {
        VAOGoal *goal = [[VAOGoal alloc] initWithDictionary:goalDict];
        if (goal) [goals addObject:goal];
    }

    //Variation
    VAOVariation *variation = [[VAOVariation alloc] initWithDictionary:campaignDict[kVariation]];
    if (variation) [self setVariation:variation];

    return [self initWithID:iD name:name trackUserOnLaunch:trackUserOnLaunch campaignStatus:campaignStatus segmentObject:segmentObject goals:goals variation:variation];
}

- (nullable id)variationForKey:(NSString*)key {
    NSParameterAssert(key);
    if (self.variation.isControl) return nil;
    NSDictionary *changes = self.variation.changes;
    if (changes == nil) return nil;
    return changes[key];//If key does not exist NSDictionary returns nil
}

- (nullable VAOGoal *)goalForIdentifier:(NSString *)identifier {
    NSParameterAssert(identifier);
    for (VAOGoal *goal in self.goals) {
        if ([goal.identifier isEqualToString:identifier]) {
            return goal;
        }
    }
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%d)", self.name, self.iD];
}

@end
