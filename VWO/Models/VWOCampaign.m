//
//  VWOCampaign.m
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import "VWOCampaign.h"
#import "NSDictionary+VWO.h"
#import "VWOLogger.h"

static NSString * kId                   = @"id";
static NSString * kName                 = @"name";
static NSString * kTrackUserOnLaunch    = @"track_user_on_launch";
static NSString * kStatus               = @"status";
static NSString * kSegmentObject        = @"segment_object";
static NSString * kGoals                = @"goals";
static NSString * kVariation            = @"variations";

@implementation VWOCampaign

- (nullable instancetype)initWithDictionary:(NSDictionary *) campaignDict {
    NSParameterAssert(campaignDict);

    // Campaign ID and status are the must have keys for any type of campaign
    NSArray *mustHaveKeys = @[kId, kStatus];
    NSArray *missingKeys  = [campaignDict keysMissingFrom:mustHaveKeys];
    if (missingKeys.count > 0) {
        VWOLogException(@"Keys missing [%@] for Campaign JSON {%@}", [missingKeys componentsJoinedByString:@", "], campaignDict);
        return nil;
    }

    if (self = [super init]) {
        self.iD = [campaignDict[kId] intValue];
    }

    NSString *statusString = campaignDict[kStatus];

    if ([statusString isEqualToString:@"EXCLUDED"]) {
        self.status = CampaignStatusExcluded;
        return self;
    }

    if([statusString isEqualToString:@"PAUSED"]) {
        self.status = CampaignStatusPaused;
        return self;
    }

    // Status
    if ([statusString isEqualToString:@"RUNNING"]) {

        //Check key validity only if the campaigns are running
        NSArray *mustHaveKeys = @[kName, kTrackUserOnLaunch, kGoals, kVariation];
        NSArray *missingKeys  = [campaignDict keysMissingFrom:mustHaveKeys];
        if (missingKeys.count > 0) {
            VWOLogException(@"Keys missing [%@] for Running Campaign JSON {%@}", [missingKeys componentsJoinedByString:@", "], campaignDict);
            return nil;
        }

        self.status    = CampaignStatusRunning;
        self.name              = campaignDict[kName];
        self.trackUserOnLaunch = [campaignDict[kTrackUserOnLaunch] boolValue];
        self.segmentObject     = campaignDict[kSegmentObject];

        //Goals
        NSMutableArray<VWOGoal *>*goals = [NSMutableArray new];
        NSArray *goalsDict = campaignDict[kGoals];
        for (NSDictionary *goalDict in goalsDict) {
            VWOGoal *goal = [[VWOGoal alloc] initWithDictionary:goalDict];
            if (goal) [goals addObject:goal];
        }
        self.goals = goals;

        //Variation
        VWOVariation *variation = [[VWOVariation alloc] initWithDictionary:campaignDict[kVariation]];
        if (variation) self.variation = variation;
        return self;
    }
    return nil;
}

- (nullable id)variationForKey:(NSString *)key {
    NSParameterAssert(key);
    NSDictionary *changes = self.variation.changes;
    if (changes == nil) return nil;
    return changes[key];//If key does not exist NSDictionary returns nil
}

- (nullable VWOGoal *)goalForIdentifier:(NSString *)identifier {
    NSParameterAssert(identifier);
    for (VWOGoal *goal in self.goals) {
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
