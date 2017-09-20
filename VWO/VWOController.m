//
//  VWOController.m
//  VWO
//
//  Created by Wingify on 25/11/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VWOController.h"
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
#import "VWOMakeURL.h"
#import "VWORavenClient.h"
#import "VWOSDK.h"

static NSString *const kWaitTill   = @"waitTill";
static NSString *const kURL        = @"url";
static NSString *const kRetryCount = @"retry";

@interface VWOController ()

@property (atomic) NSMutableArray<VWOCampaign *> *campaignList;
@property NSMutableDictionary<NSString *, NSString *> *customVariables;

@end

@implementation VWOController {
    NSMutableDictionary *previewInfo; // holds the set of changes to be used during preview mode
    VWOMessageQueue *messageQueue;
    NSTimer *messageQueueFlushtimer;
}

- (id)init {
    if (self = [super init]) {
        self.previewMode = NO;
        _customVariables = [NSMutableDictionary new];
        _campaignList    = [NSMutableArray new];
        _customVariables = [NSMutableDictionary new];
    }
    return self;
}

+ (instancetype)sharedInstance{
    static VWOController *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)initializeAsynchronously:(BOOL)async
                         timeout:(NSTimeInterval)timeout
                    withCallback:(void(^)(void))completionBlock
                         failure:(void(^)(void))failureBlock {
    VWOPersistantStore.sessionCount += 1;
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
    [self setupSentry];
}

- (void)setupSentry {
    NSDictionary *tags = @{@"VWO Account id" : VWOSDK.accountID,
                           @"SDK Version" : VWOSDK.version};

    //CFBundleDisplayName & CFBundleIdentifier can be nil
    NSMutableDictionary *extras = [NSMutableDictionary new];
    extras[@"App Name"] = NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"];
    extras[@"BundleID"] = NSBundle.mainBundle.infoDictionary[@"CFBundleIdentifier"];

    NSString *DSN = @"https://c3f6ba4cf03548f3bd90066dd182a649:6d6d9593d15944849cc9f8d88ccf1fb0@sentry.io/41858";
    VWORavenClient *client = [VWORavenClient clientWithDSN:DSN extra:extras tags:tags];

    [VWORavenClient setSharedClient:client];
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

// Sends request on all the url on a background thread
- (void)flushQueue:(VWOMessageQueue *)queue {
    VWOLogInfo(@"Sending all messages in queue");
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger count = queue.count;
        VWOLogDebug(@"Total messages in queue %t", count);
        while (count > 0) {
            NSMutableDictionary *urlDict = [queue.peek mutableCopy];

            // Queue is empty
            if (urlDict == nil) continue;
            VWOLogDebug(@"Trying message %t", count);
            // If now() < WaitTill time then dont consider this message
            if (urlDict[kWaitTill] != nil) {
                NSTimeInterval now = NSDate.date.timeIntervalSince1970;
                if (now < [urlDict[kWaitTill] doubleValue]) {
                    VWOLogDebug(@"Not sending. Waiting for time %@", [NSDate dateWithTimeIntervalSince1970:[urlDict[kWaitTill] doubleValue]]);
                    continue;
                }
            }

            NSString *url = urlDict[kURL];
            NSError *error = nil;
            NSURLResponse *response = nil;
            VWOLogDebug(@"Sending request %@", url);
            [NSURLSession.sharedSession sendSynchronousDataTaskWithURL:[NSURL URLWithString:url] returningResponse:&response error:&error];

            //If No internet connection break; No need to process other messages in queue
            if (error != nil && error.code == NSURLErrorNotConnectedToInternet) {
                VWOLogInfo(@"No internet connection. Aborting queue flush");
                break;
                //Note: If there is other error but response status is 200, still it might be a successful request
            }

            [queue removeFirst];

            if (response != nil) {
                // Failure is confirmed only when status is not 200
                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                if (statusCode != 200) {
                    urlDict[kRetryCount] = @([urlDict[kRetryCount] intValue] + 1);
                    VWOLogDebug(@"Re inserting message with retry count %@", urlDict[kRetryCount]);
                    [queue enqueue:urlDict];
                }
            }

            count -= 1;
        }//while
    });
}

/// Creates NSArray of Type VWOCampaign and stores in self.campaignList
- (void)updateCampaignListFromDictionary:(NSArray *)allCampaignDict {
    VWOLogInfo(@"Updating campaignList from URL response");
    for (NSDictionary *campaignDict in allCampaignDict) {
        VWOCampaign *aCampaign = [[VWOCampaign alloc] initWithDictionary:campaignDict];
        if (!aCampaign) continue;

        if (aCampaign.status == CampaignStatusExcluded) {
            [self trackUserForCampaign:aCampaign];
            continue;
        }

        if (aCampaign.status == CampaignStatusRunning) {
            if (aCampaign.trackUserOnLaunch) {
                if ([VWOSegmentEvaluator canUserBePartOfCampaignForSegment:aCampaign.segmentObject customVariables:_customVariables]) {
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

        NSURL *url = [VWOMakeURL forMakingUserPartOfCampaign:campaign dateTime:NSDate.date];
        [messageQueue enqueue:@{kURL : url, kRetryCount : @(0)}];

        [self sendNotificationUserStartedTracking:campaign];
    }
}

- (void)sendNotificationUserStartedTracking:(VWOCampaign *)campaign {
    VWOLogInfo(@"Sending notfication user started tracking %@", campaign);
    //Note: All values in campaignInfo dictionary must be in string format
    NSDictionary *campaignInfo = @{@"vwo_campaign_name"  : campaign.name.copy,
                                   @"vwo_campaign_id"    : [NSString stringWithFormat:@"%d", campaign.iD],
                                   @"vwo_variation_name" : campaign.variation.name.copy,
                                   @"vwo_variation_id"   : [NSString stringWithFormat:@"%d", campaign.variation.iD],
                                   };
    [NSNotificationCenter.defaultCenter postNotificationName:VWOUserStartedTrackingInCampaignNotification object:nil userInfo:campaignInfo];
}


- (void)setCustomVariable:(NSString *)variable withValue:(NSString *)value {
    VWOLogInfo(@"Set variable: %@ = %@", variable, value);
    _customVariables[variable] = value;
}

- (void)applicationDidEnterBackground {
}

- (void)applicationWillEnterForeground {
    //TODO: Start timer
    // IF campaign info is 1 hr old refetch it
}

- (void)dealloc{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)fetchCampaignsSynchronouslyForTimeout:(NSTimeInterval)timeout {

    NSURLRequest *request = [NSURLRequest requestWithURL:VWOMakeURL.forFetchingCampaigns cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeout];

    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLSession.sharedSession sendSynchronousDataTaskWithRequest:request returningResponse:&response error:&error];

    if (error) {
        if ([NSFileManager.defaultManager fileExistsAtPath:VWOFile.campaignCache.path]) {
            VWOLogWarning(@"%@", error.localizedDescription);
            VWOLogInfo(@"Loading Cached Response");
            NSArray *cachedCampaings = [NSArray arrayWithContentsOfURL:VWOFile.campaignCache];
            [self updateCampaignListFromDictionary:cachedCampaings];
        } else {
            VWOLogError(@"Campaigns fetch failed. Cache not available {%@}", error.localizedDescription);
        }
        return;
    }
    NSError *jsonerror;
    NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonerror];

    [responseArray writeToURL:VWOFile.campaignCache atomically:YES];
    [self updateCampaignListFromDictionary:responseArray];
}

- (void)fetchCampaignsAsynchronouslyWithCallback:(void (^)(void))completionBlock
                               failure:(void (^)(void))failureBlock {

    [NSURLSession.sharedSession dataTaskWithURL:VWOMakeURL.forFetchingCampaigns completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if ([NSFileManager.defaultManager fileExistsAtPath:VWOFile.campaignCache.path]) {
                VWOLogWarning(@"Network failed while fetching campaigns {%@}", error.localizedDescription);
                VWOLogInfo(@"Loading Cached Response");
                NSArray *cachedCampaings = [NSArray arrayWithContentsOfURL:VWOFile.campaignCache];
                [self updateCampaignListFromDictionary:cachedCampaings];
            } else {
                VWOLogError(@"Campaigns fetch failed. Cache not available {%@}", error.localizedDescription);
                if (failureBlock) failureBlock();
            }
            return;
        }
        NSError *jsonerror;
        NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonerror];
        [responseArray writeToURL:VWOFile.campaignCache atomically:YES];
        [self updateCampaignListFromDictionary:responseArray];
        if (completionBlock) completionBlock();
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
    for (VWOCampaign *campaign in _campaignList) {
        VWOGoal *matchedGoal = [campaign goalForIdentifier:goalIdentifier];
        if (matchedGoal) {
            if ([VWOPersistantStore isGoalMarked:matchedGoal]) {
                VWOLogDebug(@"Goal '%@' already marked. Will not be marked again", matchedGoal);
                return;
            }
        }
    }

    // Mark goal(One goal can be present in multiple campaigns
    for (VWOCampaign *campaign in _campaignList) {
        if ([VWOPersistantStore isTrackingUserForCampaign:campaign]) {
            VWOGoal *matchedGoal = [campaign goalForIdentifier:goalIdentifier];
            if (matchedGoal) {
                [VWOPersistantStore markGoalConversion:matchedGoal];
                NSURL *url = [VWOMakeURL forMarkingGoal:campaign goal:matchedGoal dateTime:NSDate.date withValue:value];
                [messageQueue enqueue:@{kURL : url, kRetryCount : @(0)}];
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

    id finalVariation = nil;
    for (VWOCampaign *campaign in _campaignList) {
        id variation = [campaign variationForKey:key];

        //If variation Key is present in Campaign
        if (variation) {
            finalVariation = variation;
            // If campaign is not already tracked; check if it can be part of campaign.
            if ([VWOSegmentEvaluator canUserBePartOfCampaignForSegment:campaign.segmentObject customVariables:_customVariables]) {
                [self trackUserForCampaign:campaign];
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
