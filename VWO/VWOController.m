//
//  VWOController.m
//  VWO
//
//  Created by Wingify on 25/11/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VWOController.h"
#import "VWOModel.h"
#import "VWOAPIClient.h"
#import "VWOSocketClient.h"
#import "VWOLogger.h"
#import "VWOPersistantStore.h"
#import "VWOSegmentEvaluator.h"
#import "VWOFile.h"
#import "VWOCampaign.h"
#import <UIKit/UIKit.h>

static const NSTimeInterval kMinUpdateTimeGap = 60*60; // seconds in 1 hour

@implementation VWOController {
    BOOL remoteDataDownloading;
    NSTimeInterval lastUpdateTime;
    NSMutableDictionary *previewInfo; // holds the set of changes to be used during preview mode
    NSMutableDictionary *customVariables;
}

- (void)initializeAsynchronously:(BOOL)async
                         timeout:(NSTimeInterval)timeout
                    withCallback:(void(^)(void))completionBlock
                         failure:(void(^)(void))failureBlock {
    VWOPersistantStore.sessionCount += 1;
    [VWOAPIClient.sharedInstance initializeAndStartTimer];
    if (async) {
        [self fetchCampaignsAsynchronouslyWithCallback:completionBlock failure:failureBlock];
    } else {
        [self fetchCampaignsSynchronouslyForTimeout:timeout];
    }
    [self addBackgroundListeners];
}

- (void)addBackgroundListeners {
    NSNotificationCenter *notification = NSNotificationCenter.defaultCenter;
    [notification addObserver:self
                     selector:@selector(applicationDidEnterBackground)
                         name:UIApplicationDidEnterBackgroundNotification object:nil];
    [notification addObserver:self
                     selector:@selector(applicationWillEnterForeground)
                         name:UIApplicationWillEnterForegroundNotification object:nil];
}

+ (instancetype)sharedInstance{
    static VWOController *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        remoteDataDownloading = NO;
        lastUpdateTime        = 0;
        self.previewMode      = NO;
        customVariables       = [NSMutableDictionary new];
    }
    return self;
}

- (void)setCustomVariable:(NSString *)variable withValue:(NSString *)value {
    VWOLogInfo(@"Set variable: %@ = %@", variable, value);
    VWOModel.sharedInstance.customVariables[variable] = value;
}

- (void)applicationDidEnterBackground {
    if(!self.previewMode) {
        lastUpdateTime = NSDate.timeIntervalSinceReferenceDate;
        [VWOAPIClient.sharedInstance stopTimer];
    }
}

- (void)applicationWillEnterForeground {
    [VWOAPIClient.sharedInstance startTimer];
    if(remoteDataDownloading == NO) {
        NSTimeInterval currentTime = NSDate.timeIntervalSinceReferenceDate;
        if(currentTime - lastUpdateTime < kMinUpdateTimeGap){
            return;
        }
        [self fetchCampaignsAsynchronouslyWithCallback:nil failure:nil];
    }
}

-(void)dealloc{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)fetchCampaignsSynchronouslyForTimeout:(NSTimeInterval)timeout {
    remoteDataDownloading = YES;
    NSError *error;
    id responseObject = [VWOAPIClient.sharedInstance fetchCampaignsSynchronouslyForTimeout:timeout error:&error];
    remoteDataDownloading = NO;
    if (error) {
        if ([NSFileManager.defaultManager fileExistsAtPath:VWOFile.campaignCache.path]) {
            VWOLogWarning(@"%@", error.localizedDescription);
            VWOLogInfo(@"Loading Cached Response");
            NSArray *cachedCampaings = [NSArray arrayWithContentsOfURL:VWOFile.campaignCache];
            [VWOModel.sharedInstance updateCampaignListFromDictionary:cachedCampaings];
        } else {
            VWOLogError(@"Campaigns fetch failed. Cache not available {%@}", error.localizedDescription);
        }
        return;
    }
    lastUpdateTime  = NSDate.timeIntervalSinceReferenceDate;
    [(NSArray *) responseObject writeToURL:VWOFile.campaignCache atomically:YES];
    [VWOModel.sharedInstance updateCampaignListFromDictionary:responseObject];
}

- (void)fetchCampaignsAsynchronouslyWithCallback:(void (^)(void))completionBlock
                               failure:(void (^)(void))failureBlock {

    remoteDataDownloading      = YES;

    [VWOAPIClient.sharedInstance fetchCampaignsAsynchronouslyOnSuccess:^(id responseObject) {
        lastUpdateTime        = NSDate.timeIntervalSinceReferenceDate;
        remoteDataDownloading = NO;

        [(NSArray *) responseObject writeToURL:VWOFile.campaignCache atomically:YES];
        [VWOModel.sharedInstance updateCampaignListFromDictionary:responseObject];
        if (completionBlock) completionBlock();
    } failure:^(NSError *error) {
        if ([NSFileManager.defaultManager fileExistsAtPath:VWOFile.campaignCache.path]) {
            VWOLogWarning(@"Network failed while fetching campaigns {%@}", error.localizedDescription);
            VWOLogInfo(@"Loading Cached Response");
            NSArray *cachedCampaings = [NSArray arrayWithContentsOfURL:VWOFile.campaignCache];
            [VWOModel.sharedInstance updateCampaignListFromDictionary:cachedCampaings];
        } else {
            VWOLogError(@"Campaigns fetch failed. Cache not available {%@}", error.localizedDescription);
            if (failureBlock) failureBlock();
        }
    }];
}

- (void)preview:(NSDictionary *)changes {
    previewInfo = changes[@"json"];
}

- (void)markConversionForGoal:(NSString*)goalIdentifier withValue:(NSNumber*)value {
    
    if (self.previewMode) {
        [VWOSocketClient.sharedInstance goalTriggered:goalIdentifier withValue:value];
        return;
    }

    //Check if the goal is already marked
    NSArray<VWOCampaign *> *campaignList = VWOModel.sharedInstance.campaignList;
    for (VWOCampaign *campaign in campaignList) {
        VWOGoal *matchedGoal = [campaign goalForIdentifier:goalIdentifier];
        if (matchedGoal) {
            if ([VWOPersistantStore isGoalMarked:matchedGoal]) {
                VWOLogDebug(@"Goal '%@' already marked. Will not be marked again", matchedGoal);
                return;
            }
        }
    }

    // Mark goal(One goal can be present in multiple campaigns
    for (VWOCampaign *campaign in campaignList) {
        if ([VWOPersistantStore isTrackingUserForCampaign:campaign]) {
            VWOGoal *matchedGoal = [campaign goalForIdentifier:goalIdentifier];
            if (matchedGoal) {
                [VWOModel.sharedInstance markGoalConversion:matchedGoal inCampaign:campaign withValue:value];
            }
        }
    }
}

- (id)variationForKey:(NSString *)key {
    if (self.previewMode) {
        if(key && previewInfo) {
            return previewInfo[key];
        }
        return nil;
    }

    NSMutableArray<VWOCampaign *> *campaignList = VWOModel.sharedInstance.campaignList;

    id finalVariation = nil;
    for (VWOCampaign *campaign in campaignList) {
        id variation = [campaign variationForKey:key];

        //If variation Key is present in Campaign
        if (variation) {
            finalVariation = variation;
            // If campaign is not already tracked; check if it can be part of campaign.
            if ([VWOSegmentEvaluator canUserBePartOfCampaignForSegment:campaign.segmentObject]) {
                [VWOModel.sharedInstance trackUserForCampaign:campaign];
            }

        }
    }
    if (finalVariation == [NSNull null]) {
//        finalVariation can be NSNull if Control is assigned to campaign
        return nil;
    }
    return finalVariation;
}

@end
