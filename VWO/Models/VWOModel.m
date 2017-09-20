//
//  VWOModel.m
//  VWO
//
//  Created by Wingify on 26/08/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VWOModel.h"
#import "VWOAPIClient.h"
#import "VWOLogger.h"
#import "VWOPersistantStore.h"
#import "VWOSegmentEvaluator.h"
#import "VWOFile.h"
#import "VWOCampaign.h"
#import "VWO.h"

@implementation VWOModel

+ (instancetype)sharedInstance{
    static VWOModel *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        self.campaignList = [NSMutableArray new];
        _customVariables = [NSMutableDictionary new];
    }
    return self;
}

/// Creates NSArray of Type VWOCampaign and stores in self.campaignList
- (void)updateCampaignListFromDictionary:(NSArray *)allCampaignDict {
    for (NSDictionary *campaignDict in allCampaignDict) {
        VWOCampaign *aCampaign = [[VWOCampaign alloc] initWithDictionary:campaignDict];
        if (!aCampaign) continue;

        if (aCampaign.status == CampaignStatusExcluded) {
            [self trackUserForCampaign:aCampaign];
            continue;
        }

        if (aCampaign.status == CampaignStatusRunning) {
            if (aCampaign.trackUserOnLaunch) {
                if ([VWOSegmentEvaluator canUserBePartOfCampaignForSegment:aCampaign.segmentObject]) {
                    [self.campaignList addObject:aCampaign];
                    VWOLogInfo(@"Received Campaign: '%@' Variation: '%@'", aCampaign, aCampaign.variation);
                } else { //Segmentation failed
                    VWOLogInfo(@"User cannot be part of campaign: '%@'", aCampaign);
                }
            } else {//Unconditionally add when NOT trackUserOnLaunch
                [self.campaignList addObject:aCampaign];
                VWOLogInfo(@"Received Campaign: '%@' Variation: '%@'", aCampaign, aCampaign.variation);
            }
        }
    }

    //TODO: Put in above loop, else put the reason of separtate loop
    //Track users for campaigns that have trackUserOnLaunch enabled
    for (VWOCampaign *campaign in self.campaignList) {
        if (campaign.trackUserOnLaunch) {
            [self trackUserForCampaign:campaign];
        }
    }
}

/// Sends network request to mark user tracking for campaign
/// Sets "campaignId : variation id" in persistance store
- (void)trackUserForCampaign:(VWOCampaign *)campaign {
    NSParameterAssert(campaign);
    if ([VWOPersistantStore isTrackingUserForCampaign:campaign]) {
        // Return if already tracking
        return;
    }

    // Set User to be returning if not already set.
    if (!VWOPersistantStore.isReturningUser) VWOPersistantStore.returningUser = YES;

    [VWOPersistantStore trackUserForCampaign:campaign];

    //Send network request and notification only if the campaign is running
    if (campaign.status == CampaignStatusRunning) {
        VWOLogInfo(@"Making user part of Campaign: '%@'", campaign);
        [VWOAPIClient.sharedInstance makeUserPartOfCampaign:campaign];

        NSDictionary *campaignInfo = @{
                                       @"vwo_campaign_name"  : campaign.name.copy,
                                       @"vwo_campaign_id"    : [NSString stringWithFormat:@"%d", campaign.iD],
                                       @"vwo_variation_name" : campaign.variation.name.copy,
                                       @"vwo_variation_id"   : [NSString stringWithFormat:@"%d", campaign.variation.iD],
                                       };
        [NSNotificationCenter.defaultCenter postNotificationName:VWOUserStartedTrackingInCampaignNotification object:nil userInfo:campaignInfo];
    }
}

- (void)markGoalConversion:(VWOGoal *)goal inCampaign:(VWOCampaign *)campaign withValue:(NSNumber *)number {
    NSParameterAssert(goal);
    NSParameterAssert(campaign);
    VWOLogInfo(@"Marking Goal: '%@'", goal);
    [VWOPersistantStore markGoalConversion:goal];
    [VWOAPIClient.sharedInstance markConversionForGoalId:goal.iD experimentId:campaign.iD variationId:campaign.variation.iD revenue:number];
}

- (void)saveMessages:(NSArray *)messages {
    [messages writeToURL:VWOFile.messages atomically:YES];
}

@end
