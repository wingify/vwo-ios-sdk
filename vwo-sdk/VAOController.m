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
    BOOL _remoteDataDownloading;
    NSTimeInterval _lastUpdateTime;
    NSMutableDictionary *previewInfo; // holds the set of changes to be used during preview mode
    NSMutableDictionary *customVariables;
}

+ (void)initializeAsynchronously:(BOOL)async
                    withCallback:(void(^)(void))completionBlock
                         failure:(void(^)(void))failureBlock {
    [VAOPersistantStore incrementSessionCount];
    [[VAOAPIClient sharedInstance] initializeAndStartTimer];
    [[self sharedInstance] downloadCampaignAsynchronously:async withCallback:completionBlock failure:failureBlock];
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

- (void)setCustomVariable:(NSString *)variable withValue:(NSString *)value {
    VAOLogInfo(@"Set variable: %@ = %@", variable, value);
    VAOModel.sharedInstance.customVariables[variable] = value;
}

- (void)applicationDidEnterBackground {
    if(!self.previewMode) {
        _lastUpdateTime = [NSDate timeIntervalSinceReferenceDate];
        [VAOAPIClient.sharedInstance stopTimer];
    }
}

- (void)applicationWillEnterForeground {
    [VAOAPIClient.sharedInstance startTimer];
    if(_remoteDataDownloading == NO) {
        NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
        if(currentTime - _lastUpdateTime < kMinUpdateTimeGap){
            return;
        }
        [self downloadCampaignAsynchronously:YES withCallback:nil failure:nil];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)downloadCampaignAsynchronously:(BOOL)async
                          withCallback:(void (^)(void))completionBlock
                               failure:(void (^)(void))failureBlock {

    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    _remoteDataDownloading = YES;

    [VAOAPIClient.sharedInstance fetchCampaigns:async success:^(id responseObject) {
        _lastUpdateTime = currentTime;
        _remoteDataDownloading = NO;

        VAOLogInfo(@"%lu campaigns received", (unsigned long)[(NSArray *) responseObject count]);
        [(NSArray *) responseObject writeToURL:VAOFile.campaignCachePath atomically:YES];
        [VAOModel.sharedInstance updateCampaignListFromDictionary:responseObject];
        if (completionBlock) completionBlock();
    } failure:^(NSError *error) {
        if ([NSFileManager.defaultManager fileExistsAtPath:VAOFile.campaignCachePath.path]) {
            VAOLogWarning(@"Network failed while fetching campaigns {%@}", error.localizedDescription);
            VAOLogInfo(@"Loading Cached Response");
            NSArray *cachedCampaings = [NSArray arrayWithContentsOfURL:VAOFile.campaignCachePath];
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
    NSArray<VAOCampaign *> *campaignList = [[VAOModel sharedInstance] campaignList];
    for (VAOCampaign *campaign in campaignList) {
        VAOGoal *matchedGoal = [campaign goalForIdentifier:goalIdentifier];
        if (matchedGoal) {
            if ([VAOPersistantStore isGoalMarked:matchedGoal]) {
                VAOLogDebug(@"%@ already marked. Will not be marked again", matchedGoal);
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
    if (self.previewMode) {
        if(key && previewInfo) {
            return previewInfo[key];
        }
        return nil;
    }
    
    NSMutableArray<VAOCampaign *> *campaignList = [[VAOModel sharedInstance] campaignList];

    for (VAOCampaign *campaign in campaignList) {
        id variation = [campaign variationForKey:key];
        if (variation) { //If variation Key is present in Campaign
            if ([VAOPersistantStore isTrackingUserForCampaign:campaign]) {
                // already tracking
                return [variation copy];
            } else {
                // check for segmentation
                if ([VWOSegmentEvaluator canUserBePartOfCampaignForSegment:campaign.segmentObject]) {
                    [[VAOModel sharedInstance] trackUserForCampaign:campaign];
                    return [variation copy];
                }
            }
        }
    }
    return nil;
}

@end
