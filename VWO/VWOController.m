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
#import "VWOSegmentEvaluator.h"
#import "VWOCampaign.h"
#import <UIKit/UIKit.h>
#import "VWOMessageQueue.h"
#import "VWOFile.h"
#import "NSURLSession+Synchronous.h"
#import "VWOURL.h"
#import "VWORavenClient.h"
#import "VWODevice.h"
#import "VWOConfig.h"

static NSString *const kWaitTill                 = @"waitTill";
static NSString *const kURL                      = @"url";
static NSString *const kRetryCount               = @"retry";
#ifdef VWO_DEBUG
static NSTimeInterval kMessageQueueFlushInterval = 5;
#else
static NSTimeInterval kMessageQueueFlushInterval = 20;
#endif
static NSTimeInterval kMaxTotalRetryCount        = 10;
static NSTimeInterval const defaultReqTimeout    = 60;
static NSString *kSDKversion                     = @"2.0.0-beta7";

@interface VWOController()

@property (atomic) NSArray<VWOCampaign *> *campaignList;

@end

@implementation VWOController {
    VWOMessageQueue *messageQueue;
    NSTimer *messageQueueFlushtimer;
    dispatch_queue_t _vwoQueue;
    BOOL _initialised;
}

#pragma mark - Public methods

+ (instancetype)shared{
    static VWOController *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (dispatch_queue_t) taskQueue {
    return VWOController.shared->_vwoQueue;
}

- (void)launchWithAPIKey:(NSString *)apiKey
             withTimeout:(NSNumber *)timeout
            withCallback:(void(^)(void))completionBlock
                 failure:(void(^)(NSString *error))failureBlock {

    NSAssert([apiKey componentsSeparatedByString:@"-"].count == 2, @"Invalid key");
    NSAssert([apiKey componentsSeparatedByString:@"-"].firstObject.length == 32, @"Invalid key");

    if (_initialised) {
        VWOLogWarning(@"VWO must not be initialised more than once");
        return;
    }

    #ifdef VWO_DEBUG
        VWOLogInfo(@"Initializing VWO with VWO_DEBUG");
    #else
        VWOLogInfo(@"Initializing VWO");
    #endif

    NSArray<NSString *> *splitKey = [apiKey componentsSeparatedByString:@"-"];
    _config = [[VWOConfig alloc] initWithAccountID:splitKey[1] appKey:splitKey[0] sdkVersion:kSDKversion];

    _config.sessionCount += 1;
    [self setupSentry];

    if (VWODevice.isAttachedToDebugger) {
        dispatch_async(dispatch_get_main_queue(), ^{
                //UIWebKit is used. Hence dispatched on main Queue
            [VWOSocketClient.shared launchAppKey:_config.appKey];
        });
    }

    // Initialise the queue and flush the persistance URLs
    messageQueue = [[VWOMessageQueue alloc] initWithFileURL:VWOFile.messageQueue];
    [self flushQueue:messageQueue tryAll:true];

    // Start timer. (Timer can be scheduled only on Main Thread)
    dispatch_async(dispatch_get_main_queue(), ^{
        messageQueueFlushtimer = [NSTimer scheduledTimerWithTimeInterval:kMessageQueueFlushInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self flushQueue:messageQueue tryAll:false];
        }];
    });

    _campaignList = [self getCampaignListWithTimeout:timeout WithCallback:completionBlock failure:failureBlock];
    for (VWOCampaign *campaign in _campaignList) {
        VWOLogInfo(@"********* Got Campaigns %@", campaign);
    }
    if (_campaignList == nil) return;
    _initialised = true;
    [self trackUserForAllCampaignsOnLaunch:_campaignList];
}


/**
 Fetch campaigns from network
 If campaigns not available the returns campaigns from cache

 @return Array of campaigns. nil if network returns 400. nil if campaign list not available on network and cache
 */
- (nullable NSArray<VWOCampaign *> *)getCampaignListWithTimeout:(NSNumber *)timeout
                                          WithCallback:(void(^)(void))completionBlock
                                               failure:(void(^)(NSString *error))failureBlock {
    VWOLogInfo(@"getCampaignListWithTimeout");
    NSString *errorString;
    NSArray<NSDictionary *> *jsonArray = [self getCampaignsFromNetworkWithTimeout:timeout onFailure:&errorString];
    if (errorString != nil) {
        VWOLogError(errorString);
        if (failureBlock) failureBlock(errorString);
        return nil;
    }
    if (jsonArray == nil) jsonArray = [NSArray arrayWithContentsOfURL:VWOFile.campaignCache];
    if (jsonArray == nil) {
        VWOLogWarning(@"No campaigns available. No cache available");
        return nil;
    }
    NSArray<VWOCampaign *> *allCampaigns = [self campaignsFromJSON:jsonArray];
    NSArray<VWOCampaign *> *evaluatedCampaigns = [self segmentEvaluated:allCampaigns];
    if (completionBlock) completionBlock();
    return  evaluatedCampaigns;
}

- (void)markConversionForGoal:(NSString *)goalIdentifier withValue:(NSNumber *)value {
    if (!_initialised) {
        VWOLogError(@"VWO must be launched first!");
        return;
    }
    VWOLogDebug(@"Controller markConversionForGoal");

    if (VWOSocketClient.shared.isEnabled) {
        VWOLogDebug(@"Marking goal on socket");
        [VWOSocketClient.shared goalTriggered:goalIdentifier withValue:value];
        return;
    }

        //Check if the goal is already marked
    for (VWOCampaign *campaign in _campaignList) {
        VWOGoal *matchedGoal = [campaign goalForIdentifier:goalIdentifier];
        if (matchedGoal) {
            if ([_config isGoalMarked:matchedGoal]) {
                VWOLogDebug(@"Goal '%@' already marked. Will not be marked again", matchedGoal);
                return;
            }
        }
    }

        // Mark goal(One goal can be present in multiple campaigns
    for (VWOCampaign *campaign in _campaignList) {
        if ([_config isTrackingUserForCampaign:campaign]) {
            VWOGoal *matchedGoal = [campaign goalForIdentifier:goalIdentifier];
            if (matchedGoal) {
                [_config markGoalConversion:matchedGoal];
                NSURL *url = [VWOURL forMarkingGoal:matchedGoal withValue:value campaign:campaign dateTime:NSDate.date config:_config];
                [messageQueue enqueue:@{kURL : url.absoluteString, kRetryCount : @(0)}];
            }
        }
    }
}

- (id)variationForKey:(NSString *)key {
    if (!_initialised) {
        VWOLogWarning(@"variationForKey(%@) called before launching VWO", key);
        return nil;
    }
    if (VWOSocketClient.shared.isEnabled) {
        if(key && _previewInfo != nil) {
            return _previewInfo[key];
        }
        return nil;
    }

    id finalVariation = nil;
    for (VWOCampaign *campaign in _campaignList) {
        id variation = [campaign variationForKey:key];

            //If variation Key is present in Campaign
        if (variation) {
            finalVariation = variation;
            [self trackUserForCampaign:campaign];
        }
    }
    if (finalVariation == [NSNull null]) {
        // finalVariation can be NSNull if Control is assigned to campaign
        return nil;
    }
    return finalVariation;
}

#pragma mark - Private methods

- (id)init {
    if (self = [super init]) {
        _campaignList    = [NSMutableArray new];
        _segmentEvaluator = [VWOSegmentEvaluator new];
        _vwoQueue = dispatch_queue_create("com.vwo.tasks", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)setupSentry {
    VWOLogDebug(@"Sentry setup");
    NSDictionary *tags = @{@"VWO Account id" : _config.accountID,
                           @"SDK Version" : _config.sdkVersion};

    //CFBundleDisplayName & CFBundleIdentifier can be nil
    NSMutableDictionary *extras = [NSMutableDictionary new];
    extras[@"App Name"] = NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"];
    extras[@"BundleID"] = NSBundle.mainBundle.infoDictionary[@"CFBundleIdentifier"];

    NSString *DSN = @"https://c3f6ba4cf03548f3bd90066dd182a649:6d6d9593d15944849cc9f8d88ccf1fb0@sentry.io/41858";
    VWORavenClient *client = [VWORavenClient clientWithDSN:DSN extra:extras tags:tags];

    [VWORavenClient setSharedClient:client];
}

- (void)sendNotificationUserStartedTracking:(VWOCampaign *)campaign {
    VWOLogInfo(@"Controller: Sending notfication user started tracking %@", campaign);
    //Note: All values in campaignInfo dictionary must be in string format
    NSDictionary *campaignInfo = @{@"vwo_campaign_name"  : campaign.name.copy,
                                   @"vwo_campaign_id"    : [NSString stringWithFormat:@"%d", campaign.iD],
                                   @"vwo_variation_name" : campaign.variation.name.copy,
                                   @"vwo_variation_id"   : [NSString stringWithFormat:@"%d", campaign.variation.iD],
                                   };
    [NSNotificationCenter.defaultCenter postNotificationName:VWOUserStartedTrackingInCampaignNotification object:nil userInfo:campaignInfo];
}

/**
 Creates and Array of VWOCampaign from campaign json array.

 */
- (NSArray <VWOCampaign *> *) campaignsFromJSON:(NSArray<NSDictionary *> *)jsonArray {
    NSMutableArray<VWOCampaign *> *newCampaignList = [NSMutableArray new];
    for (NSDictionary *campaignDict in jsonArray) {
        VWOCampaign *aCampaign = [[VWOCampaign alloc] initWithDictionary:campaignDict];
        if (aCampaign) [newCampaignList addObject:aCampaign];
    }
    return newCampaignList;
}

/**
 Evaluate all the campaigns using Segmentation
 */
- (NSArray <VWOCampaign *> *) segmentEvaluated:(NSArray <VWOCampaign *> *)allCampaigns {
    NSMutableArray<VWOCampaign *> *newCampaignList = [NSMutableArray new];
    for (VWOCampaign *aCampaign in allCampaigns) {
        if ([_segmentEvaluator canUserBePartOfCampaignForSegment:aCampaign.segmentObject config:_config]) {
            [newCampaignList addObject:aCampaign];
        }
    }
    return newCampaignList;
}

/**
 Tracks all the campaigns that have `trackUserOnLaunch` enabled
 Call this in launch method
 */
- (void)trackUserForAllCampaignsOnLaunch:(NSArray<VWOCampaign *> *) allCampaigns {
    VWOLogInfo(@"trackUserForAllCampaignsOnLaunch");
    for (VWOCampaign *aCampaign in allCampaigns) {
        if (aCampaign.status == CampaignStatusExcluded) {
            [_config trackUserForCampaign:aCampaign];
            continue;
        } else if (aCampaign.status == CampaignStatusRunning && aCampaign.trackUserOnLaunch) {
            if ([_segmentEvaluator canUserBePartOfCampaignForSegment:aCampaign.segmentObject config:_config]) {
                [self trackUserForCampaign:aCampaign];
            }
        }
    }
}

- (nullable NSArray *)getCampaignsFromNetworkWithTimeout:(NSNumber *)timeout onFailure:(NSString **)errorString {
    NSURL *url = [VWOURL forFetchingCampaignsConfig:_config];
    VWOLogDebug(@"fetchCampaigns URL(%@)", url.absoluteString);
    NSTimeInterval timeOutInterval = (timeout == nil) ? defaultReqTimeout : timeout.doubleValue;
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeOutInterval];

    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLSession.sharedSession sendSynchronousDataTaskWithRequest:request returningResponse:&response error:&error];

    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    if(statusCode >= 400 && statusCode <= 499) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        VWOLogError(@"Client side error %@", json[@"message"]);
        *errorString = json[@"message"];
        return nil;
    }
    if (statusCode >= 500 && statusCode <=599) return nil;

    NSError *jsonerror;
    NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonerror];
    if (jsonerror != nil) return nil;
    return responseArray;
}

/// Creates NSArray of Type VWOCampaign and stores in self.campaignList
- (void)updateCampaignListFromDictionary:(NSArray *)allCampaignDict {
    NSParameterAssert(allCampaignDict);
    VWOLogInfo(@"Updating campaignList from URL response");
    NSMutableArray<VWOCampaign *> *newCampaignList = [NSMutableArray new];
    for (NSDictionary *campaignDict in allCampaignDict) {
        VWOCampaign *aCampaign = [[VWOCampaign alloc] initWithDictionary:campaignDict];
        if (!aCampaign) continue;

        if (aCampaign.status == CampaignStatusExcluded) {
            [self trackUserForCampaign:aCampaign];
            continue;
        }

        if (aCampaign.status == CampaignStatusRunning) {
            if (aCampaign.trackUserOnLaunch) {
                if ([_segmentEvaluator canUserBePartOfCampaignForSegment:aCampaign.segmentObject config:_config]) {
                    [newCampaignList addObject:aCampaign];
                    [self trackUserForCampaign:aCampaign];
                    VWOLogInfo(@"Received Campaign: '%@' Variation: '%@'", aCampaign, aCampaign.variation);
                } else { //Segmentation failed
                    VWOLogInfo(@"User cannot be part of campaign: '%@'", aCampaign);
                }
            } else {//Unconditionally add when NOT trackUserOnLaunch
                [newCampaignList addObject:aCampaign];
                VWOLogInfo(@"Received Campaign: '%@' Variation: '%@'", aCampaign, aCampaign.variation);
            }
        }
    }
    _campaignList = newCampaignList;
    VWOLogDebug(@"Total Campaigns %d", _campaignList.count);
}

/**
 Returns if the campaign is already tracked

 Stores campaign:variation pair in _config

 Enqueue in message queue and sends notification

 @param campaign campaign that is to be tracked
 */
- (void)trackUserForCampaign:(VWOCampaign *)campaign {
    NSParameterAssert(campaign);
    NSAssert(campaign.status == CampaignStatusRunning, @"Non running campaigns must not be tracked");

    if ([_config isTrackingUserForCampaign:campaign]) {
        VWOLogDebug(@"Controller: Returning. Already tracking %@", campaign);
        return;
    }
    VWOLogDebug(@"Controller: trackUserForCampaign %@", campaign);

    [_config trackUserForCampaign:campaign];

    //Send network request and notification only if the campaign is running
    NSURL *url = [VWOURL forMakingUserPartOfCampaign:campaign config:_config dateTime:NSDate.date];
    [messageQueue enqueue:@{kURL : url.absoluteString, kRetryCount : @(0)}];

    [self sendNotificationUserStartedTracking:campaign];
}

/**
 Flush all the URLS present in the Queue.
 Internally its been dispatched on low priority background thread

 @param queue queue that is to be flushed
 @param tryAll If set will try to hit all the URLS irrespective of the error
 */
- (void)flushQueue:(VWOMessageQueue *)queue tryAll:(BOOL)tryAll {
    VWOLogInfo(@"Sending all messages in queue");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSUInteger count = queue.count;
        VWOLogDebug(@"Total messages in queue %d", count);
        for (; count > 0; count -= 1) {
            NSMutableDictionary *firstObject = [queue.peek mutableCopy];

            NSAssert(firstObject != nil, @"queue.peek is giving invalid results");
            VWOLogDebug(@"Trying message at %d", count);

            NSString *url = firstObject[kURL];
            NSError *error = nil;
            NSURLResponse *response = nil;
            VWOLogDebug(@"Sending request %@", url);
            [NSURLSession.sharedSession sendSynchronousDataTaskWithURL:[NSURL URLWithString:url] returningResponse:&response error:&error];

            //If No internet connection break; No need to process other messages in queue
            if (error != nil) {
                VWOLogError(error.localizedDescription);
                if (tryAll == false) break;
            }

            // Failure is confirmed only when status is not 200
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            int retryCount = [firstObject[kRetryCount] intValue];
            if (statusCode == 200 || retryCount > kMaxTotalRetryCount){
                VWOLogInfo(@"Successfully sent message %d", statusCode);
                [queue dequeue];
            } else {
                firstObject[kRetryCount] = @(retryCount + 1);
                VWOLogDebug(@"Re inserting message with retry count %@", firstObject[kRetryCount]);
                [queue dequeue];
                [queue enqueue:firstObject];
            }
        }//for
    });
}

- (void)dealloc{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end
