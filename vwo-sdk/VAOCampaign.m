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

- (instancetype)initWithID:(int)iD
                    name:(NSString *)name
       trackUesrOnLaunch:(BOOL) trackUserOnLaunch
                  campaignStatus:(CampaignStatus)campaignStatus
          segmentObjects:(NSDictionary *)segmentObjects
                   goals:(NSArray<VAOGoal *>*)goals
               variation:(VAOVariation *)variation {
    if (self = [super init]) {
        self.iD = iD;
        self.name = name;
        self.trackUserOnLaunch = trackUserOnLaunch;
        self.campaignStatus = campaignStatus;
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
    CampaignStatus campaignStatus = CampaignStatusRunning;
    NSString *statusString = [campaignDict[kStatus] stringValue];
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

    return [self initWithID:iD name:name trackUesrOnLaunch:trackUserOnLaunch campaignStatus:campaignStatus segmentObjects:segmentObjects goals:goals variation:variation];
}

- (nullable id)variationForKey:(NSString*)key {
    NSDictionary *changes = self.variation.changes;
    return changes[key];//If key does not exist NSDictionary returns nil
}

- (nullable VAOGoal *)goalForidentifier:(NSString *)identifier {
    for (VAOGoal *goal in self.goals) {
        if ([goal.identifier isEqualToString:identifier]) {
            return [goal copy];
        }
    }
    return nil;
}
#pragma mark - NSCoding

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    int iD = [aDecoder decodeIntForKey:kId];
    NSString *name = [aDecoder decodeObjectForKey:kName];
    BOOL track = [aDecoder decodeBoolForKey:kTrackUserOnLaunch];
    CampaignStatus status = [aDecoder decodeIntegerForKey:kStatus];
    NSDictionary *segmenObjects = [aDecoder decodeObjectForKey:kSegmentObject];
    NSArray<VAOGoal *>* goals = [aDecoder decodeObjectForKey:kGoals];
    VAOVariation *variation = [aDecoder decodeObjectForKey:kVariation];
    return [self initWithID:iD name:name trackUesrOnLaunch:track campaignStatus:status segmentObjects:segmenObjects goals:goals variation:variation];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.iD forKey:kId];
    [aCoder encodeObject:self.name forKey:kName];
    [aCoder encodeBool:self.trackUserOnLaunch forKey:kTrackUserOnLaunch];
    [aCoder encodeInteger:self.campaignStatus forKey:kStatus];
    [aCoder encodeObject:self.segmentObjects forKey:kSegmentObject];
    [aCoder encodeObject:self.goals forKey:kGoals];
    [aCoder encodeObject:self.variation forKey:kVariation];
}

@end
