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
#import "VWOMessageQueue.h"
#import "VWOFile.h"
#import "NSURLSession+Synchronous.h"
#import "VWO.h"

static const NSTimeInterval kMinUpdateTimeGap = 60*60; // seconds in 1 hour

@interface VWOController ()

@property (atomic) NSMutableArray<VWOCampaign *> *campaignList;
@property NSMutableDictionary<NSString *, NSString *> *customVariables;

@end

@implementation VWOController {
    BOOL remoteDataDownloading;
    NSTimeInterval lastUpdateTime;
    NSMutableDictionary *previewInfo; // holds the set of changes to be used during preview mode
//    NSMutableDictionary *customVariables;
    VWOMessageQueue *messageQueue;
    NSTimer *messageQueueFlushtimer;
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

    messageQueue = [[VWOMessageQueue alloc] initWithFileURL:VWOFile.messageQueue];
    messageQueueFlushtimer = [NSTimer scheduledTimerWithTimeInterval:20 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self flushQueue:messageQueue];
    }];
    [self addBackgroundListeners];
}

static NSString *const kWaitTill = @"waitTill";
static NSString *const kURL = @"url";
static NSString *const kRetryCount = @"retry";

// Sends request on all the url on a background thread
- (void)flushQueue:(VWOMessageQueue *)queue {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger count = queue.count;
        while (count > 0) {
            NSMutableDictionary *urlDict = [queue.peek mutableCopy];

            // Queue is empty
            if (urlDict == nil) continue;

            // If now() < WaitTill time then dont consider this message
            if (urlDict[kWaitTill] != nil) {
                NSTimeInterval now = NSDate.date.timeIntervalSince1970;
                if (now < [urlDict[kWaitTill] doubleValue]) {
                    continue;
                }
            }

            NSString *url = urlDict[kURL];
            NSError *error = nil;
            NSURLResponse *response = nil;
            [NSURLSession.sharedSession sendSynchronousDataTaskWithURL:[NSURL URLWithString:url] returningResponse:&response error:&error];

            [queue removeFirst];

            //If No internet connection break; No need to process other messages in queue
            if (error != nil && error.code == NSURLErrorNotConnectedToInternet) {
                break;
                //Note: If there is other error but response status is 200, still it might be a successful request
            }

            if (response != nil) {
                // Failure is confirmed only when status is not 200
                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                if (statusCode != 200) {
                    urlDict[kRetryCount] = @([urlDict[kRetryCount] intValue] + 1);
                    [queue enqueue:urlDict];
                }
            }

            count -= 1;
        }//while
    });
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
        instance.campaignList = [NSMutableArray new];
        instance.customVariables = [NSMutableDictionary new];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        remoteDataDownloading = NO;
        lastUpdateTime        = 0;
        self.previewMode      = NO;
        _customVariables       = [NSMutableDictionary new];
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

- (void)dealloc{
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
