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

- (void)downLoadCampaignInfoAsynchronously:(BOOL)async
                   withCurrentCampaignInfo:(NSMutableDictionary *) currentPairs
                                completion:(void(^)(NSMutableArray *info))completionBlock {
        
    [[VAOAPIClient sharedInstance] pullABData:currentPairs success:^(NSMutableArray *array) {
        [VAOLogger info:[NSString stringWithFormat:@"Array: %@", array]];
        
        if (completionBlock) {
            completionBlock(array);
        }
    } failure:^(NSError *error) {
        [VAOLogger errorStr:[NSString stringWithFormat:@"Failed to connect to the VAO server to download AB logs. %@\n", error]];
    } isSynchronous:!async];
}

- (NSString *)campaignInfoPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/VWOCampaignInfo.plist"];
}

- (NSMutableDictionary*)getCampaignInfo {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self campaignInfoPath]];
    return dict;
}

- (void)saveCampaignInfo:(NSDictionary *)campaignInfo {
    /**
     * we assume that `meta` is the unabridged meta to be saved and is not polluted by any merging of old/original values.
     * Original values, in particular, may not be serializable at all, e.g., images.
     */
    @try {
        [campaignInfo writeToFile:[self campaignInfoPath] atomically:YES];
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
            [[VAOAPIClient sharedInstance] pushVariationRenderWithExperimentId:[experimentId integerValue]
                                                                   variationId:variationId];
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
