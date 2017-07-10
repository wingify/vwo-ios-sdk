//
//  VAOController.m
//  VAO
//
//  Created by Wingify on 25/11/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VAOController.h"
#import "VAOModel.h"
#import "VAOAPIClient.h"
#import "VAOSocketClient.h"
#import "VAOGoogleAnalytics.h"
#import "VAORavenClient.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include "VAOSDKInfo.h"
#import "VAOLogger.h"
#import "VAOPersistantStore.h"

static const NSTimeInterval kMinUpdateTimeGap = 60*60; // seconds in 1 hour

@implementation VAOController {
    BOOL _remoteDataDownloading;
    NSTimeInterval _lastUpdateTime;
    BOOL _trackUserManually;
    NSMutableDictionary *_campaignInfo; // holds the set of changes to be applied to various UI elements
    NSMutableDictionary *_activeGoals;
    NSMutableDictionary *customVariables;
}

+ (void)initializeAsynchronously:(BOOL)async withCallback:(void (^)(void))completionBlock {
    [[self sharedInstance] updateCampaignInfo];
    [[self sharedInstance] downloadCampaignAsynchronously:async withCallback:completionBlock];
    [[self sharedInstance] addBackgroundListeners];
}

-(void)addBackgroundListeners {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidEnterBackground)
                               name:UIApplicationDidEnterBackgroundNotification object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillEnterForeground)
                               name:UIApplicationWillEnterForegroundNotification object:nil];
}

+ (instancetype)sharedInstance{
    static VAOController *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        _remoteDataDownloading = NO;
        _lastUpdateTime = 0;
        self.previewMode = NO;
        _trackUserManually = NO;
        _activeGoals = [[NSMutableDictionary alloc] init];
        customVariables = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)updateCampaignInfo {
    _campaignInfo = [[VAOModel sharedInstance] getCampaignInfo];
}

- (void)setValue:(NSString*)value forCustomVariable:(NSString*)variable {
    if(!value || !variable) return;
    @try {
        [customVariables setObject:value forKey:variable];
    }
    @catch (NSException *exception) {
        [VAOLogger exception:exception];
    }
}

- (void)applicationDidEnterBackground {
    if(!self.previewMode) {
        _lastUpdateTime = [NSDate timeIntervalSinceReferenceDate];
        [[VAOAPIClient sharedInstance] stopTimer];
    }
}

- (void)applicationWillEnterForeground {
    [[VAOAPIClient sharedInstance] startTimer];
    if(_remoteDataDownloading == NO) {
        NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
        if(currentTime - _lastUpdateTime < kMinUpdateTimeGap){
            return;
        }
        [self downloadCampaignAsynchronously:YES withCallback:nil];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)downloadCampaignAsynchronously:(BOOL)async withCallback:(void (^)(void))completionBlock {
    
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    _remoteDataDownloading = YES;

    [[VAOAPIClient sharedInstance] pullABDataAsynchronously:async success:^(id responseObject) {
        _lastUpdateTime = currentTime;
        _remoteDataDownloading = NO;

        [[VAOModel sharedInstance] updateCampaignListFromNetworkResponse:responseObject];
        if (completionBlock) {
            completionBlock();
        }
    } failure:^(NSError *error) {
        [VAOLogger errorStr:[NSString stringWithFormat:@"Failed to connect to the VAO server to download AB logs. %@\n", error]];
    }];
}

- (void)trackUserManually {
    _trackUserManually = YES;
}


/**
 * This replaces the _meta with the passed in changes
 * In preview mode, we only provide the preview changes and do not provide meta of currently running experiments
 */
- (void)preview:(NSDictionary *)changes {
    // convert changes dictionary to our usable format
    NSString *experimentId = [NSString stringWithFormat:@"%i", arc4random()];
    NSString *variationId = [NSString stringWithFormat:@"%@", [changes objectForKey:@"variationId"]];
    _campaignInfo = [NSMutableDictionary dictionary];
    _campaignInfo[experimentId] = @{@"variationId":variationId, @"json":changes[@"json"]};
}

#pragma mark Goal

- (void)markConversionForGoal:(NSString*)goalIdentifier withValue:(NSNumber*)value {
    
    if (self.previewMode) {
        [[VAOSocketClient sharedInstance] goalTriggeredWithName:goalIdentifier];
        return;
    }
    
    //Check if the goal is already marked
    NSArray<VAOCampaign *> *campaignList = [[VAOModel sharedInstance] campaignList];
    for (VAOCampaign *campaign in campaignList) {
        VAOGoal *matchedGoal = [campaign goalForidentifier:goalIdentifier];
        if ([VAOPersistantStore isGoalMarked:matchedGoal]) {
            NSLog(@"Goal already marked");
            return;
        }
    }
    
    for (VAOCampaign *campaign in campaignList) {
        if ([VAOPersistantStore isTrackingUserForCampaign:campaign]) {
            VAOGoal *matchedGoal = [campaign goalForidentifier:goalIdentifier];
            [[VAOModel sharedInstance] markGoalConversion:matchedGoal inCampaign:campaign withValue:value];
        }
    }
}

- (id)variationForKey:(NSString*)key {
    NSMutableArray<VAOCampaign *> *campaignList = [[VAOModel sharedInstance] campaignList];

    for (VAOCampaign *campaign in campaignList) {
        id variation = [campaign variationForKey:key];
        if (variation) {
            //If campaign has key and `trackUserOnLaunch` is not enabled
            //then start tracking User and return the variation for key.
            if (!campaign.trackUserOnLaunch) {
                [[VAOModel sharedInstance] trackUserForCampaign:campaign];
            }
            return [variation copy];
        }
    }
    return nil;
}

- (void)trackUserInCampaign:(NSString*)key {
    if(_trackUserManually == NO) {
        return;
    }
    
    @try {
        for (NSString *expId in [_campaignInfo allKeys]) {
            NSDictionary *experiment = _campaignInfo[expId];
            
            if ([experiment[@"json"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *thisExpJSON = experiment[@"json"];
                if (thisExpJSON[key]) {
                    [self checkAndtrackUserForExperiment:expId forCampaign:experiment];
                    return;
                }
            }
            
        }
    }
    @catch (NSException *exception) {
        [VAOLogger exception:exception];
    }
}

- (void)checkAndtrackUserForExperiment:(NSString*)expId forCampaign:(NSDictionary*)experiment {
    if ([[VAOModel sharedInstance] hasBeenPartOfExperiment:expId]) {
        return;
    }
    
    // make user part of this experiment
    [[VAOModel sharedInstance] checkAndMakePartOfExperiment:expId
                                                variationId:experiment[@"variationId"]];
    
    // if UA integration is enabled
    if (experiment[@"UA"]) {
        NSNumber *dimension = (experiment[@"UA"][@"s"] ? experiment[@"UA"][@"s"]: @1);
        [[VAOGoogleAnalytics sharedInstance] experimentWithName:experiment[@"name"]
                                                   experimentId:expId
                                                  variationName:(experiment[@"variationName"] ? experiment[@"variationName"] : @"variation-name")
                                                    variationId:experiment[@"variationId"]
                                                      dimension:dimension];
    }
}
@end
