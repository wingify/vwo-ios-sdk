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
static NSString * kTrack_user_on_launch = @"track_user_on_launch";
static NSString * kStatus               = @"status";
static NSString * kSegment_object       = @"segment_object";
static NSString * kGoals                = @"goals";
static NSString * kVariation            = @"variations";
static NSString * kType                 = @"type";

@implementation VAOCampaign
- (instancetype)initWithDictionary:(NSDictionary *) campaignDict {
    self = [super init];
    if (self) {
        NSArray *mustHaveKeys = @[kId, kTrack_user_on_launch, kSegment_object, kStatus, kGoals, kVariation, kType, kName];
        if ([campaignDict hasKeys:mustHaveKeys]) {
            [self setId:[campaignDict[kId] intValue]];
            [self setName:[campaignDict[kName] stringValue]];
            [self setTrackUserOnLaunch:[campaignDict[kTrack_user_on_launch] boolValue]];

            // Status
            NSString *status = [campaignDict[kStatus] stringValue];
            if ([status isEqualToString:@"RUNNING"]) {
                [self setStatus:CampaignStatusRunning];
            } else if ([status isEqualToString:@"EXCLUED"]) {
                [self setStatus:CampaignStatusExcluded];
            }

            //Goals
            NSArray *goals = campaignDict[kGoals];
            for (NSDictionary *goalDict in goals) {
                VAOGoal *goal = [[VAOGoal alloc] initWithDictionary:goalDict];
                if (goal) [self.goals addObject:goal];
            }

            //Variation
            VAOVariation *variation = [[VAOVariation alloc] initWithDictionary:campaignDict[kVariation]];
            if (variation) [self setVariation:variation];
        }
    }
    return self;

}
@end
