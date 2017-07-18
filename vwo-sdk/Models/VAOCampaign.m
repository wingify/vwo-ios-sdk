//
//  VAOCampaign.m
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import "VAOCampaign.h"
#import "NSDictionary+VWO.h"
#import "VAORavenClient.h"

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
          segmentObject:(nullable NSDictionary *)segmentObject
                   goals:(NSArray<VAOGoal *>*)goals
               variation:(VAOVariation *)variation {
    NSParameterAssert(name);
    NSParameterAssert(goals);
    NSParameterAssert(variation);
    if (self = [super init]) {
        self.iD = iD;
        self.name = name;
        self.trackUserOnLaunch = trackUserOnLaunch;
        self.campaignStatus = campaignStatus;
        self.segmentObject = segmentObject;
        self.goals = goals;
        self.variation = variation;
    }
    return [self init];
}

- (nullable instancetype)initWithDictionary:(NSDictionary *) campaignDict {
    NSParameterAssert(campaignDict);
    NSArray *mustHaveKeys = @[kId, kName, kTrackUserOnLaunch, kStatus, kGoals, kVariation];
    NSArray *missingKeys = [campaignDict keysMissingFrom:mustHaveKeys];
    if (missingKeys.count > 0) {
        NSLog(@"Campaign Keys missing %@", [missingKeys componentsJoinedByString:@", "]);
        VAORavenCaptureMessage(@"Campaign Keys missing %@", [missingKeys componentsJoinedByString:@", "]);
        return nil;
    }

    int iD = [campaignDict[kId] intValue];
    NSString * name = campaignDict[kName];
    BOOL trackUserOnLaunch = [campaignDict[kTrackUserOnLaunch] boolValue];
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

    return [self initWithID:iD name:name trackUesrOnLaunch:trackUserOnLaunch campaignStatus:campaignStatus segmentObject:segmentObject goals:goals variation:variation];
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
    return [NSString stringWithFormat:@"{{[%@ (%d)] [%@ (%d)]}}", self.name, self.iD, self.variation.name, self.variation.iD];
}

#pragma mark - NSCoding

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    int iD = [aDecoder decodeIntForKey:kId];
    NSString *name = [aDecoder decodeObjectForKey:kName];
    BOOL track = [aDecoder decodeBoolForKey:kTrackUserOnLaunch];
    CampaignStatus status = [aDecoder decodeIntegerForKey:kStatus];
    NSDictionary *segmentObject = [aDecoder decodeObjectForKey:kSegmentObject];
    NSArray<VAOGoal *>* goals = [aDecoder decodeObjectForKey:kGoals];
    VAOVariation *variation = [aDecoder decodeObjectForKey:kVariation];
    return [self initWithID:iD name:name trackUesrOnLaunch:track campaignStatus:status segmentObject:segmentObject goals:goals variation:variation];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.iD forKey:kId];
    [aCoder encodeObject:self.name forKey:kName];
    [aCoder encodeBool:self.trackUserOnLaunch forKey:kTrackUserOnLaunch];
    [aCoder encodeInteger:self.campaignStatus forKey:kStatus];
    [aCoder encodeObject:self.segmentObject forKey:kSegmentObject];
    [aCoder encodeObject:self.goals forKey:kGoals];
    [aCoder encodeObject:self.variation forKey:kVariation];
}

@end
