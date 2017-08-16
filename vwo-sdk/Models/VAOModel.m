//
//  VAOModel.m
//  VAO
//
//  Created by Wingify on 26/08/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VAOModel.h"
#import "VAOAPIClient.h"
#import "VAOLogger.h"
#import "VAOPersistantStore.h"
#import "VWOSegmentEvaluator.h"
#import "VAOGoogleAnalytics.h"

@implementation VAOModel

+ (instancetype)sharedInstance{
    static VAOModel *instance = nil;
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

/// Creates NSArray of Type VAOCampaign and stores in self.campaignList
- (void)updateCampaignListFromDictionary:(NSArray *)allCampaignDict {
    for (NSDictionary *campaignDict in allCampaignDict) {
        VAOCampaign *aCampaign = [[VAOCampaign alloc] initWithDictionary:campaignDict];
        if (!aCampaign) {
            VAOLogException(@"Invalid campaign received {%@}", campaignDict);
            continue;
        }
        if (aCampaign.trackUserOnLaunch) {
            if ([VWOSegmentEvaluator canUserBePartOfCampaignForSegment:aCampaign.segmentObject]) {
                [self.campaignList addObject:aCampaign];
                VAOLogInfo(@"Campaign: '%@' Variation: '%@'", aCampaign.name, aCampaign.variation.name);
            } else { //Segmentation failed
                VAOLogInfo(@"User cannot be part of campaign: '%@'", aCampaign);
            }
        } else {//Unconditionally add when NOT trackUserOnLaunch
            [self.campaignList addObject:aCampaign];
            VAOLogInfo(@"Campaign: '%@' Variation: '%@'", aCampaign.name, aCampaign.variation.name);
        }
    }

    //Track users for campaigns that have trackUserOnLaunch enabled
    for (VAOCampaign *campaign in self.campaignList) {
        if (campaign.trackUserOnLaunch &&
            ![VAOPersistantStore isTrackingUserForCampaign:campaign]) {
            [self trackUserForCampaign:campaign];
        }
    }
}

/// Sends network request to mark user tracking for campaign
/// Sets "campaignId : variation id" in persistance store
- (void)trackUserForCampaign:(VAOCampaign *)campaign {
    NSParameterAssert(campaign);
    VAOLogInfo(@"Making user part of campaign: '%@'", campaign.name);
    if (![VAOPersistantStore returningUser]) [VAOPersistantStore setReturningUser:YES];
    [VAOPersistantStore trackUserForCampaign:campaign];
    [VAOAPIClient.sharedInstance makeUserPartOfCampaign:campaign];
    if (campaign.gaDimension) {
        [VAOGoogleAnalytics.sharedInstance makeUserPartOfCampaign:campaign];
    }
}

- (void)markGoalConversion:(VAOGoal *)goal inCampaign:(VAOCampaign *)campaign withValue:(NSNumber *) number {
    NSParameterAssert(goal);
    NSParameterAssert(campaign);
    VAOLogInfo(@"Marking goal: '%@' (%d)", goal.identifier, goal.iD);
    [VAOPersistantStore markGoalConversion:goal];
    [[VAOAPIClient sharedInstance] markConversionForGoalId:goal.iD experimentId:campaign.iD variationId:campaign.variation.iD revenue:number];
    if (campaign.gaDimension) {
        [VAOGoogleAnalytics.sharedInstance markGoalConversion:goal inCampaign:campaign withValue:number];
    }
}

- (NSString *) pendingMessagesPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/VWOPendingMessages.plist"];
}

- (NSArray *)loadMessagesFromFile {
    return [NSArray arrayWithContentsOfFile:[self pendingMessagesPath]];
}

- (void)saveMessages:(NSArray *)messages {
    [messages writeToFile:[self pendingMessagesPath] atomically:YES];
}

@end
