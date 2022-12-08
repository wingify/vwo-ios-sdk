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
#import "VWOGroup.h"

static NSString * kId = @"id";
static NSString * kName = @"name";
static NSString * kTrackUserOnLaunch = @"track_user_on_launch";
static NSString * kStatus = @"status";
static NSString * kSegmentObject = @"segment_object";
static NSString * kGoals = @"goals";
static NSString * kVariation = @"variations";
static NSString * kTestKey = @"test_key";
static NSString * kType = @"type";
static NSString * CAMPAIGN_GROUPS = @"groups";
@implementation VWOCampaign

- (nullable instancetype)initWithDictionary:(NSDictionary *) campaignDict {
    NSParameterAssert(campaignDict);

    // Campaign ID and status are the must have keys for any type of campaign
    NSArray *mustHaveKeys = @[kId, kStatus, kType];
    NSArray *missingKeys = [campaignDict keysMissingFrom:mustHaveKeys];
    if (missingKeys.count > 0) {
        VWOLogException(@"Keys missing [%@] for Campaign JSON {%@}",
                        [missingKeys componentsJoinedByString:@", "],
                        campaignDict);
        return nil;
    }

    if (self = [super init]) {
        self.iD = [campaignDict[kId] intValue];
        NSString *statusString = campaignDict[kStatus];

        self.type = campaignDict[kType];
        if ([statusString isEqualToString:@"EXCLUDED"]) {
            self.status = CampaignStatusExcluded;
            self.name = campaignDict[kName];
            return self;
        }



        if([statusString isEqualToString:@"PAUSED"]) {

            self.status = CampaignStatusPaused;

            return self;

        }



        //Here Campaign can only running

        NSArray *mustHaveKeys = @[kName, kTrackUserOnLaunch, kGoals, kVariation];

        NSArray *missingKeys = [campaignDict keysMissingFrom:mustHaveKeys];

        if (missingKeys.count > 0) {

            VWOLogException(@"Keys missing [%@] for Running Campaign JSON {%@}",

                            [missingKeys componentsJoinedByString:@", "],

                            campaignDict);

            return nil;

        }

        self.status = CampaignStatusRunning;
        self.name = campaignDict[kName];
        self.testKey = campaignDict[kTestKey];
        self.trackUserOnLaunch = [campaignDict[kTrackUserOnLaunch] boolValue];
        self.segmentObject = campaignDict[kSegmentObject];
        
        //Goals
        NSMutableArray<VWOGoal *>*goals = [NSMutableArray new];
        NSArray *goalsDict = campaignDict[kGoals];
        for (NSDictionary *goalDict in goalsDict) {
            VWOGoal *goal = [[VWOGoal alloc] initWithDictionary:goalDict];
            if (goal) [goals addObject:goal];
        }
        self.goals = goals;

        //Variation
        self.variation = [[VWOVariation alloc] initWithDictionary:campaignDict[kVariation]];

    }
    if([self.type isEqualToString:CAMPAIGN_GROUPS]){
        self.group = [[VWOGroup alloc] initWithDictionary:campaignDict];
    }
    return self;
}

-(nullable instancetype)setGroups:(NSDictionary *) campaignDict{
    self.type = CAMPAIGN_GROUPS;
    self.group = [[VWOGroup alloc] initWithDictionary:campaignDict];
    
    return  self;
}

- (nullable id)testKey:(NSString *)testKey {
    NSParameterAssert(testKey);
    //If key does not exist then NSDictionary returns nil
    return self.testKey;
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

-(nullable VWOGroup *)groupForMeg{
    if([self.type isEqualToString:CAMPAIGN_GROUPS]){
        return self.group;
    }
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(id: %d)", self.name, self.iD];
}

@end
