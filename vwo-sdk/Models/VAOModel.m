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
#import "VAOUserActivity.h"

@implementation VAOModel

NSMutableDictionary *campaigns;

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
        self.campaignList = [[VAOModel loadCampaignsFromFile] mutableCopy];
        NSString *campaignsPlist = [self userCampaignsPath];
        campaigns = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:campaignsPlist]];
        if ([[campaigns allKeys] count] > 0) {
            [VAOSDKInfo setReturningVisitor:YES];
        }
    }
    return self;
}

- (NSString*)userCampaignsPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/VWOUserCampaigns.plist"];
}

/// Creates NSArray of Type VAOCampaign and stores in self.campaignList
- (void)updateCampaignListFromNetworkResponse:(NSArray *)allCampaignDict {
    for (NSDictionary *campaignDict in allCampaignDict) {
        VAOCampaign *aCampaign = [[VAOCampaign alloc] initWithDictionary:campaignDict];
        if (aCampaign) [self.campaignList addObject:aCampaign];
    }

    //Persist User tracking for all the valid campaigns
    for (VAOCampaign *campaign in self.campaignList) {
        //If user is not already being tracked and trackUserOnLaunch is enabled
        //then inform backend and store in UserActivity
        if (![VAOUserActivity isTrackingUserForCampaign:campaign] &&
            campaign.trackUserOnLaunch) {
            [self trackUserForCampaign:campaign];
        }
    }
}

/// Sends network request to mark user tracking for campaign
/// Sets "campaignId : variation id" in persistance store
- (void)trackUserForCampaign:(VAOCampaign *)campaign {
    [VAOUserActivity trackUserForCampaign:campaign];
    NSString *variationID = [NSString stringWithFormat:@"%d", campaign.variation.id];
    [[VAOAPIClient sharedInstance] makeUserPartOfCampaign:campaign.iD forVariation:variationID];
}

- (void)markGoalConversion:(VAOGoal *)goal {
    //TODO: Network activity pending. Send tracking info to Network
    [VAOUserActivity markGoalConversion:goal];
}

+ (NSString *)campaignInfoPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/VWOCampaignInfo.plist"];
}

- (NSMutableDictionary*)getCampaignInfo {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[VAOModel campaignInfoPath]];
    return dict;
}

- (void)serializeCampaigns {
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:self.campaignList];
    [archivedData writeToFile:[VAOModel campaignInfoPath] atomically:YES];
    NSLog(@"CAmpaign info written to File %@", [VAOModel campaignInfoPath]);
}

+ (nullable NSArray<VAOCampaign *> *)loadCampaignsFromFile {
    NSData *archivedData = [NSData dataWithContentsOfFile:[self campaignInfoPath]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
}

- (void)saveCampaignInfo:(NSDictionary *)campaignInfo {
    /**
     * we assume that `meta` is the unabridged meta to be saved and is not polluted by any merging of old/original values.
     * Original values, in particular, may not be serializable at all, e.g., images.
     */
    @try {
        [campaignInfo writeToFile:[VAOModel campaignInfoPath] atomically:YES];
    }
    @catch (NSException *exception) {
        [VAOLogger exception:exception];
    }
}

- (NSString *) pendingMessagesPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/VWOPendingMessages.plist"];
}

- (NSArray *)loadMessages {
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

/**
 *  Returns YES is user has been made part of the experiment id
 *  Returns NO otherwise
 */
- (BOOL)hasBeenPartOfExperiment:(NSString*)experimentId {
    return (campaigns[experimentId] != nil && ([campaigns[experimentId][@"varId"] isEqualToString:@"0"] == NO));
}

- (NSMutableDictionary*)getCurrentExperimentsVariationPairs {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSDictionary *campaignCopy = [campaigns copy];
    
    for (NSDictionary *experimentId in campaignCopy) {
        dictionary[experimentId] = campaignCopy[experimentId][@"varId"];
    }
    return dictionary;
}

/**
    maintain list of expid-varid
    find exp-id for key,
    if this exp-id exists then already a part, otherwise make part and insert this exp id
 
 */
- (void)checkAndMakePartOfExperiment:(NSString*)experimentId variationId:(NSString*)variationId{
    if (campaigns[experimentId] == nil) {
        campaigns[experimentId] = @{@"varId":variationId};
        
        @try {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSString *campaignsPlist = [self userCampaignsPath];
                [[campaigns copy] writeToFile:campaignsPlist atomically:YES];
            });
        }
        @catch (NSException *exception) {
            [VAOLogger exception:exception];
        }
        if ([variationId isEqualToString:@"0"] == NO) {
//            [[VAOAPIClient sharedInstance]pushVariationRenderWithExperimentId:[experimentId integerValue] variationId:variationId];
        }
    }
}

/**
 *  Returns YES if goal has never been triggered
 *  Returns NO otherwise
 */
- (BOOL)shouldTriggerGoal:(NSString*)goalId forExperiment:(NSString*)experimentId {
    NSMutableDictionary *experimentDict = [NSMutableDictionary dictionaryWithDictionary:campaigns[experimentId]];
    NSArray *goals = experimentDict[@"goals"];
    if ([goals containsObject:goalId] == NO) {
        NSMutableArray *newGoalsArray = [NSMutableArray arrayWithArray:goals];
        [newGoalsArray addObject:goalId];
        experimentDict[@"goals"] = newGoalsArray;
        campaigns[experimentId] = experimentDict;
        NSString *campaignsPlist = [self userCampaignsPath];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[campaigns copy] writeToFile:campaignsPlist atomically:YES];
        });
        return YES;
    }
    
    return NO;
}

@end
