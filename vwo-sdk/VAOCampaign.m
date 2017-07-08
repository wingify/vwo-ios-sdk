//
//  VAOCampaign.m
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import "VAOCampaign.h"
#import "NSDictionary+VWO.h"

static NSString * kId                   = @"id";
static NSString * kName                 = @"name";
static NSString * kTrackUserOnLaunch    = @"track_user_on_launch";
static NSString * kStatus               = @"status";
static NSString * kSegmentObject        = @"segment_object";
static NSString * kGoals                = @"goals";
static NSString * kVariation            = @"variations";

@implementation VAOCampaign

- (instancetype)initWithId:(int)iD
                    name:(NSString *)name
       trackUesrOnLaunch:(BOOL) trackUserOnLaunch
                  status:(CampaignStatus)status
          segmentObjects:(NSDictionary *)segmentObjects
                   goals:(NSArray<VAOGoal *>*)goals
               variation:(VAOVariation *)variation {
    if (self = [super init]) {
        self.id = iD;
        self.name = name;
        self.trackUserOnLaunch = trackUserOnLaunch;
        self.status = status;
        self.segmentObjects = segmentObjects;
        self.goals = goals;
        self.variation = variation;
    }
    return [self init];
}

- (nullable instancetype)initWithDictionary:(NSDictionary *) campaignDict {
    NSArray *mustHaveKeys = @[kId, kName, kTrackUserOnLaunch, kStatus, kSegmentObject, kGoals, kVariation];
    if (![campaignDict hasKeys:mustHaveKeys]) {
        return nil;
    }
    int iD = [campaignDict[kId] intValue];
    NSString * name = [campaignDict[kName] stringValue];
    BOOL trackUserOnLaunch = [campaignDict[kTrackUserOnLaunch] boolValue];
    NSDictionary *segmentObjects = campaignDict[kSegmentObject];

    // Status
    CampaignStatus status = CampaignStatusRunning;
    NSString *statusString = [campaignDict[kStatus] stringValue];
    if ([statusString isEqualToString:@"RUNNING"]) {
        status = CampaignStatusRunning;
    } else if ([statusString isEqualToString:@"EXCLUED"]) {
        status = CampaignStatusExcluded;
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

    return [self initWithId:iD name:name trackUesrOnLaunch:trackUserOnLaunch status:status segmentObjects:segmentObjects goals:goals variation:variation];
}
@end
