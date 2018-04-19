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

- (nullable instancetype)initWithDictionary:(NSDictionary *)campaignDict
                                  selectVariation:(NSNumber *)variationID {

    NSParameterAssert(campaignDict);

    // Campaign ID and status are the must have keys for any type of campaign
    NSArray *mustHaveKeys = @[kId, kStatus];
    NSArray *missingKeys  = [campaignDict keysMissingFrom:mustHaveKeys];
    if (missingKeys.count > 0) {
        VWOLogException(@"Keys missing [%@] for Campaign JSON {%@}",
                        [missingKeys componentsJoinedByString:@", "],
                        campaignDict);
        return nil;
    }

    if (self = [super init]) {
        self.iD = [campaignDict[kId] intValue];
        NSString *statusString = campaignDict[kStatus];

        if ([statusString isEqualToString:@"EXCLUDED"]) {
            self.status = CampaignStatusExcluded;
            self.name   = campaignDict[kName];
            return self;
        }

        if([statusString isEqualToString:@"PAUSED"]) {
            self.status = CampaignStatusPaused;
            return self;
        }

        //Here Campaign can only running
        NSArray *mustHaveKeys = @[kName, kTrackUserOnLaunch, kGoals, kVariation];
        NSArray *missingKeys  = [campaignDict keysMissingFrom:mustHaveKeys];
        if (missingKeys.count > 0) {
            VWOLogException(@"Keys missing [%@] for Running Campaign JSON {%@}",
                            [missingKeys componentsJoinedByString:@", "],
                            campaignDict);
            return nil;
        }

        self.status            = CampaignStatusRunning;
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

        //Get variation for a campaign from variationID. If variation is not found then randomly select
        NSDictionary *allVariations = campaignDict[kVariation];
        NSDictionary *selectedVariation = [self variationJSONForID:variationID from:allVariations];
        if (selectedVariation == nil) {
            selectedVariation = [VWOCampaign selectRandomVariation:campaignDict[kVariation]];
        }
        self.variation = [[VWOVariation alloc] initWithDictionary:selectedVariation];
    }
    return self;
}

/// Selects the variation from allVariations based on given variationID
/// Returns nil if not found
- (nullable NSDictionary *)variationJSONForID:(nullable NSNumber *)variationID
                                     from:(NSDictionary *)allVariations {
    if (variationID == nil) { return nil; }
    for (NSDictionary *variation in allVariations) {
        if ([variation[@"id"] intValue] == variationID.intValue) {
            return variation;
        }
    }
    return nil;
}

- (nullable id)variationForKey:(NSString *)key {
    NSParameterAssert(key);
    //If key does not exist then NSDictionary returns nil
    return self.variation.changes[key];
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

+ (NSDictionary *)selectRandomVariation:(NSArray *)allVariations {
    NSMutableArray <NSNumber *> *weights = [NSMutableArray new];
    for (NSDictionary *variation in allVariations) {
        NSNumber *weight = variation[@"weight"];
        [weights addObject:weight];
    }
    int index = [self getRandomIndexforWeights:weights];
    return allVariations[index];
}

+ (int)getRandomIndexforWeights:(NSArray <NSNumber *>*)weights {
    if (weights.count <= 1) { return 0;}
    NSMutableArray <NSNumber *> *incrementalWeights = [NSMutableArray new];
    for (NSNumber *weight in weights) {
        NSNumber *newWeight = [NSNumber numberWithInt:(weight.intValue + incrementalWeights.lastObject.intValue)];
        [incrementalWeights addObject:newWeight];
    }

    NSNumber *random = [NSNumber numberWithUnsignedInteger:arc4random() % 100];
    int i = 0;
    for (NSNumber * a in incrementalWeights) {
        if (random <= a) { return i; }
        i += 1;
    }
    return 0;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(id: %d)", self.name, self.iD];
}

@end
