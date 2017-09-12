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

- (nullable instancetype)initWithDictionary:(NSDictionary *) campaignDict {
    NSParameterAssert(campaignDict);

    // Campaign ID and status are the must have keys for any type of campaign
    NSArray *mustHaveKeys = @[kId, kStatus];
    NSArray *missingKeys  = [campaignDict keysMissingFrom:mustHaveKeys];
    if (missingKeys.count > 0) {
        VAOLogException(@"Keys missing [%@] for Campaign JSON {%@}", [missingKeys componentsJoinedByString:@", "], campaignDict);
        return nil;
    }

    if (self = [super init]) {
        self.iD = [campaignDict[kId] intValue];
    }

    NSString *statusString = campaignDict[kStatus];

    if ([statusString isEqualToString:@"EXCLUED"]) {
        self.campaignStatus = CampaignStatusExcluded;
        return self;
    }

    if([statusString isEqualToString:@"PAUSED"]) {
        self.campaignStatus = CampaignStatusPaused;
        return self;
    }

    // Status
    if ([statusString isEqualToString:@"RUNNING"]) {

        //Check key validity only if the campaigns are running
        NSArray *mustHaveKeys = @[kName, kTrackUserOnLaunch, kGoals, kVariation];
        NSArray *missingKeys  = [campaignDict keysMissingFrom:mustHaveKeys];
        if (missingKeys.count > 0) {
            VAOLogException(@"Keys missing [%@] for Running Campaign JSON {%@}", [missingKeys componentsJoinedByString:@", "], campaignDict);
            return nil;
        }

        self.campaignStatus    = CampaignStatusRunning;
        self.name              = campaignDict[kName];
        self.trackUserOnLaunch = [campaignDict[kTrackUserOnLaunch] boolValue];
        self.segmentObject     = campaignDict[kSegmentObject];

        //Goals
        NSMutableArray<VAOGoal *>*goals = [NSMutableArray new];
        NSArray *goalsDict = campaignDict[kGoals];
        for (NSDictionary *goalDict in goalsDict) {
            VAOGoal *goal = [[VAOGoal alloc] initWithDictionary:goalDict];
            if (goal) [goals addObject:goal];
        }
        self.goals = goals;

        //Variation
        VAOVariation *variation = [[VAOVariation alloc] initWithDictionary:campaignDict[kVariation]];
        if (variation) self.variation = variation;
        return self;
    }
    return nil;
}

- (nullable id)variationForKey:(NSString*)key {
    NSParameterAssert(key);
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
    return [NSString stringWithFormat:@"%@(id: %d)", self.name, self.iD];
}

@end
