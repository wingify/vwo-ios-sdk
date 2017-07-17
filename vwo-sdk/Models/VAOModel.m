//
//  VAOModel.m
//  VAO
//
//  Created by Wingify on 26/08/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VAOModel.h"
#import "VAOAPIClient.h"
#import "VAOController.h"
#import "VAORavenClient.h"
#import "VAOSDKInfo.h"
#import "VAOLogger.h"
#import "VAOPersistantStore.h"
#import "VWOSegmentEvaluator.h"

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
    }
    return self;
}

- (NSString*)userCampaignsPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/VWOUserCampaigns.plist"];
}

/// Creates NSArray of Type VAOCampaign and stores in self.campaignList
- (void)updateCampaignListFromDictionary:(NSArray *)allCampaignDict {

    for (NSDictionary *campaignDict in allCampaignDict) {
        VAOCampaign *aCampaign = [[VAOCampaign alloc] initWithDictionary:campaignDict];
        if (!aCampaign) {
            NSLog(@"ERROR: Invalid campaign received %@", campaignDict);
            continue;
        }
        if (aCampaign.trackUserOnLaunch) {
            NSDictionary *segmentObject = aCampaign.segmentObject;
            if (segmentObject) {
                if ([VWOSegmentEvaluator canUserBePartOfCampaignForSegment:segmentObject]) {
                    [self.campaignList addObject:aCampaign];
                    NSLog(@"Adding1 %@", aCampaign.description);
                } else { //Segmentation failed
                    NSLog(@"User cannot be part of campaign. Segment fail");
                }
            } else { //There is no segmentation defined for campaign. Add unconditionally
                [self.campaignList addObject:aCampaign];
                NSLog(@"Adding2 %@", aCampaign.description);
            }
        } else {//Unconditionally add when NOT trackUserOnLaunch
            [self.campaignList addObject:aCampaign];
            NSLog(@"Adding3 %@", aCampaign.description);
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
    NSLog(@"Track user for %@", campaign.description);
    if (![VAOPersistantStore returningUser]) [VAOPersistantStore setReturningUser:YES];
    [VAOPersistantStore trackUserForCampaign:campaign];
    NSString *variationID = [NSString stringWithFormat:@"%d", campaign.variation.iD];
    [[VAOAPIClient sharedInstance] makeUserPartOfCampaign:campaign.iD forVariation:variationID];
}

- (void)markGoalConversion:(VAOGoal *)goal inCampaign:(VAOCampaign *)campaign withValue:(NSNumber *) number {
    NSParameterAssert(goal);
    NSParameterAssert(campaign);
    NSLog(@"Marking goal %@ (%d)", goal.identifier, goal.iD);
    [VAOPersistantStore markGoalConversion:goal];
    [[VAOAPIClient sharedInstance] markConversionForGoalId:goal.iD experimentId:campaign.iD variationId:campaign.variation.iD revenue:number];
}

- (NSString *) pendingMessagesPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/VWOPendingMessages.plist"];
}

- (NSArray *)loadMessagesFromFile {
    return [NSArray arrayWithContentsOfFile:[self pendingMessagesPath]];
}

- (void)saveMessages:(NSArray *)messages {
    @try {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [messages writeToFile:[self pendingMessagesPath] atomically:YES];
        });

    }
    @catch (NSException *exception) {
        [VAOLogger exception:exception];
    }
}

@end
