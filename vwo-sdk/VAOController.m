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
    NSMutableDictionary *_campaignInfo; // holds the set of changes to be applied to various UI elements
    NSMutableDictionary *customVariables;
}

+ (void)initializeAsynchronously:(BOOL)async withCallback:(void (^)(void))completionBlock {
    [VAOPersistantStore incrementSessionCount];
    [[VAOAPIClient sharedInstance] initializeAndStartTimer];
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
        customVariables = [NSMutableDictionary dictionary];
    }
    return self;
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

+ (NSString *) campaignInfoPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/VWOCampaignInfo.plist"];
}

- (void)downloadCampaignAsynchronously:(BOOL)async withCallback:(void (^)(void))completionBlock {
    
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    _remoteDataDownloading = YES;

    [[VAOAPIClient sharedInstance] pullABDataAsynchronously:async success:^(id responseObject) {
        _lastUpdateTime = currentTime;
        _remoteDataDownloading = NO;
        NSLog(@"%lu campaigns received", (NSUInteger)[(NSArray *) responseObject count]);
        [(NSArray *) responseObject writeToFile:[VAOController campaignInfoPath] atomically:YES];
        [[VAOModel sharedInstance] updateCampaignListFromDictionary:responseObject];
        if (completionBlock) completionBlock();
    } failure:^(NSError *error) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[VAOController campaignInfoPath]]) {
            NSLog(@"Network failed %@", error.localizedDescription);
            NSLog(@"LOADING CACHED RESPONSE");
            [NSArray arrayWithContentsOfFile:[VAOController campaignInfoPath]];
        } else {
            NSLog(@"ABData failed. File not available %@", error.localizedDescription);
        }
    }];
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

- (void)markConversionForGoal:(NSString*)goalIdentifier withValue:(NSNumber*)value {
    
    if (self.previewMode) {
        [[VAOSocketClient sharedInstance] goalTriggeredWithName:goalIdentifier];
        return;
    }
    
    //Check if the goal is already marked
    NSArray<VAOCampaign *> *campaignList = [[VAOModel sharedInstance] campaignList];
    for (VAOCampaign *campaign in campaignList) {
        VAOGoal *matchedGoal = [campaign goalForIdentifier:goalIdentifier];
        if (matchedGoal) {
            if ([VAOPersistantStore isGoalMarked:matchedGoal]) {
                NSLog(@"%@ already marked", matchedGoal);
                return;
            }
        }
    }
    
    for (VAOCampaign *campaign in campaignList) {
        if ([VAOPersistantStore isTrackingUserForCampaign:campaign]) {
            VAOGoal *matchedGoal = [campaign goalForIdentifier:goalIdentifier];
            if (matchedGoal) {
                [[VAOModel sharedInstance] markGoalConversion:matchedGoal inCampaign:campaign withValue:value];
            }
        }
    }
}

- (id)variationForKey:(NSString*)key {
    NSMutableArray<VAOCampaign *> *campaignList = [[VAOModel sharedInstance] campaignList];

    for (VAOCampaign *campaign in campaignList) {
        id variation = [campaign variationForKey:key];
        if (variation) { //If variation Key is present in Campaign
            if (![VAOPersistantStore isTrackingUserForCampaign:campaign]) {
                [[VAOModel sharedInstance] trackUserForCampaign:campaign];
            }
            return [variation copy];
        }
    }
    return nil;
}

@end
