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
#import "VAOLogger.h"
#import "VAOPersistantStore.h"
#import "VWOSegmentEvaluator.h"
#import "VAOFile.h"
#import "VAOCampaign.h"

static const NSTimeInterval kMinUpdateTimeGap = 60*60; // seconds in 1 hour

@implementation VAOController {
    BOOL remoteDataDownloading;
    NSTimeInterval lastUpdateTime;
    NSMutableDictionary *previewInfo; // holds the set of changes to be used during preview mode
    NSMutableDictionary *customVariables;
}

- (void)initializeAsynchronously:(BOOL)async
                         timeout:(NSTimeInterval)timeout
                    withCallback:(void(^)(void))completionBlock
                         failure:(void(^)(void))failureBlock {
    VAOPersistantStore.sessionCount += 1;
    [VAOAPIClient.sharedInstance initializeAndStartTimer];
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
    static VAOController *instance = nil;
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
    VAOLogInfo(@"Set variable: %@ = %@", variable, value);
    VAOModel.sharedInstance.customVariables[variable] = value;
}

- (void)applicationDidEnterBackground {
    if(!self.previewMode) {
        lastUpdateTime = NSDate.timeIntervalSinceReferenceDate;
        [VAOAPIClient.sharedInstance stopTimer];
    }
}

- (void)applicationWillEnterForeground {
    [VAOAPIClient.sharedInstance startTimer];
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
    id responseObject = [VAOAPIClient.sharedInstance fetchCampaignsSynchronouslyForTimeout:timeout error:&error];
    remoteDataDownloading = NO;
    if (error) {
        VAOLogError(@"%@", error.localizedDescription);
        return;
    }
    lastUpdateTime  = NSDate.timeIntervalSinceReferenceDate;
    VAOLogInfo(@"%lu campaigns received", (unsigned long)[(NSArray *) responseObject count]);
    [(NSArray *) responseObject writeToURL:VAOFile.campaignCache atomically:YES];
    [VAOModel.sharedInstance updateCampaignListFromDictionary:responseObject];
}

- (void)fetchCampaignsAsynchronouslyWithCallback:(void (^)(void))completionBlock
                               failure:(void (^)(void))failureBlock {

    remoteDataDownloading      = YES;

    [VAOAPIClient.sharedInstance fetchCampaignsAsynchronouslyOnSuccess:^(id responseObject) {
        lastUpdateTime        = NSDate.timeIntervalSinceReferenceDate;
        remoteDataDownloading = NO;

        VAOLogInfo(@"%lu campaigns received", (unsigned long)[(NSArray *) responseObject count]);
        [(NSArray *) responseObject writeToURL:VAOFile.campaignCache atomically:YES];
        [VAOModel.sharedInstance updateCampaignListFromDictionary:responseObject];
        if (completionBlock) completionBlock();
    } failure:^(NSError *error) {
        if ([NSFileManager.defaultManager fileExistsAtPath:VAOFile.campaignCache.path]) {
            VAOLogWarning(@"Network failed while fetching campaigns {%@}", error.localizedDescription);
            VAOLogInfo(@"Loading Cached Response");
            NSArray *cachedCampaings = [NSArray arrayWithContentsOfURL:VAOFile.campaignCache];
            [VAOModel.sharedInstance updateCampaignListFromDictionary:cachedCampaings];
        } else {
            VAOLogWarning(@"Campaigns fetch failed. Cache not available {%@}", error.localizedDescription);
            if (failureBlock) failureBlock();
        }
    }];
}

- (void)preview:(NSDictionary *)changes {
    previewInfo = changes[@"json"];
}

- (void)markConversionForGoal:(NSString*)goalIdentifier withValue:(NSNumber*)value {
    
    if (self.previewMode) {
        [VAOSocketClient.sharedInstance goalTriggered:goalIdentifier withValue:value];
        return;
    }

    //Check if the goal is already marked
    NSArray<VAOCampaign *> *campaignList = VAOModel.sharedInstance.campaignList;
    for (VAOCampaign *campaign in campaignList) {
        VAOGoal *matchedGoal = [campaign goalForIdentifier:goalIdentifier];
        if (matchedGoal) {
            if ([VAOPersistantStore isGoalMarked:matchedGoal]) {
                VAOLogDebug(@"Goal '%@' already marked. Will not be marked again", matchedGoal);
                return;
            }
        }
    }

    // Mark goal(One goal can be present in multiple campaigns
    for (VAOCampaign *campaign in campaignList) {
        if ([VAOPersistantStore isTrackingUserForCampaign:campaign]) {
            VAOGoal *matchedGoal = [campaign goalForIdentifier:goalIdentifier];
            if (matchedGoal) {
                [VAOModel.sharedInstance markGoalConversion:matchedGoal inCampaign:campaign withValue:value];
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

    NSMutableArray<VAOCampaign *> *campaignList = VAOModel.sharedInstance.campaignList;

    id finalVariation = nil;
    for (VAOCampaign *campaign in campaignList) {
        id variation = [campaign variationForKey:key];

        //If variation Key is present in Campaign
        if (variation) {
            finalVariation = variation;
            if (![VAOPersistantStore isTrackingUserForCampaign:campaign]) {
                // If campaign is not already tracked; check if it can be part of campaign.
                if ([VWOSegmentEvaluator canUserBePartOfCampaignForSegment:campaign.segmentObject]) {
                    [VAOModel.sharedInstance trackUserForCampaign:campaign];
                }
            }
        }
    }
    if (finalVariation == [NSNull null]) {
//        finalVariation can be NSNull is Control is assigned to campaign
        return nil;
    }
    return finalVariation;
}

@end
