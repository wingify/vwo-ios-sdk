//
//  VWOController.m
//  VWO
//
//  Created by Wingify on 25/11/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VWOController.h"
#import "VWOSocketConnector.h"
#import "VWOLogger.h"
#import "VWOCampaign.h"
#import "VWOURLQueue.h"
#import "VWOFile.h"
#import "VWOURL.h"
#import "VWODevice.h"
#import "VWOUserDefaults.h"
#import <UIKit/UIKit.h>
#import "VWOConfig.h"
#import "VWOCampaignFetcher.h"
#import "VWOSegmentEvaluator.h"

static NSTimeInterval kMessageQueueFlushInterval         = 10;
static NSString *const kUserDefaultsKey = @"vwo.09cde70ba7a94aff9d843b1b846a79a7";

@interface VWOController() <VWOURLQueueDelegate>
@property (atomic) VWOCampaignArray *campaignList;
@property (nonatomic) VWOURL *vwoURL;
@property (atomic) VWOConfig *vwoConfig;
@end

@implementation VWOController {
    VWOURLQueue *pendingURLQueue;
    
    //URLS that are not successfully sent. Are loaded in failureQueue
    //Failure queue is flushed only on app launch
    VWOURLQueue *failedURLQueue;
    NSTimer *messageQueueFlushtimer;
    dispatch_queue_t _vwoQueue;
}

#pragma mark - Public methods

- (id)init {
    if (self = [super init]) {
        _campaignList    = [NSMutableArray new];
        _customVariables = [NSMutableDictionary new];
        _vwoQueue = dispatch_queue_create("com.vwo.tasks", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

+ (instancetype)shared {
    static VWOController *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (dispatch_queue_t)taskQueue {
    return VWOController.shared->_vwoQueue;
}

- (void)launchWithAPIKey:(NSString *)apiKey
              config:(VWOConfig *)configNullable
             withTimeout:(NSNumber *)timeout
            withCallback:(void(^)(void))completionBlock
                 failure:(void(^)(NSString *error))failureBlock {

    VWOConfig *config = configNullable != nil ? configNullable : [VWOConfig new];
    _vwoConfig = config;
    self.customVariables = [config.customVariables mutableCopy];
    [self updateAPIKey:apiKey];
    _vwoURL = [VWOURL urlWithAppKey:_appKey accountID:_accountID];

    if (config.optOut) {
        [self handleOptOutwithCompletion:completionBlock]; return;
    }

    if (_initialised) {
        VWOLogWarning(@"VWO must not be initialised more than once");
        if (failureBlock) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                failureBlock(@"VWO must not be initialised more than once");
            });
        }
        return;
    }

    VWOLogInfo(@"Initializing VWO with key %@", apiKey);

    [VWOUserDefaults setDefaultsKey:kUserDefaultsKey];
    VWOUserDefaults.sessionCount += 1;

    if (config.disablePreview == NO) { [self handleSocket]; }

    [self updateQueues];

    // Start timer. (Timer can be scheduled only on Main Thread)
    dispatch_async(dispatch_get_main_queue(), ^{
        self->messageQueueFlushtimer = [NSTimer scheduledTimerWithTimeInterval:kMessageQueueFlushInterval
                                                                  target:self
                                                                selector:@selector(timerAction)
                                                                userInfo:nil repeats:YES];
    });
    NSURL *url = [_vwoURL forFetchingCampaigns:config.userID];
    _campaignList = [VWOCampaignFetcher getCampaignsWithTimeout:timeout
                                                            url:url
                                   withCallback:completionBlock
                                        failure:failureBlock];

    if (_campaignList == nil) { return; }
    _initialised = true;
    [self trackUserForAllCampaignsOnLaunch:_campaignList];
}

- (void)updateAPIKey:(NSString *)apiKey {
    NSAssert([apiKey componentsSeparatedByString:@"-"].count == 2, @"Invalid key");
    NSAssert([apiKey componentsSeparatedByString:@"-"].firstObject.length == 32, @"Invalid key");

    NSArray<NSString *> *splitKey = [apiKey componentsSeparatedByString:@"-"];
    _appKey     = splitKey[0];
    _accountID  = splitKey[1];
}

- (void)handleOptOutwithCompletion:(void(^)(void))completionBlock {
    VWOLogWarning(@"Cannot launch. VWO opted out");
    [self clearVWOData];
    if (completionBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completionBlock();
        });
    }
}

- (void)handleSocket {
    if (VWOSocketConnector.isSocketLibraryAvailable) {
        if (VWODevice.isAttachedToDebugger) {
            VWOLogDebug(@"Phone attached to Mac. Initializing socket connection");
            [VWOSocketConnector launchWithAppKey:_appKey];
        } else {
            VWOLogDebug(@"Gesture recognizer added.");
            [self addGestureRecognizer];
        }
    } else {
        VWOLogDebug(@"Initializing without socket library");
    }
}

    // Initialise the queue and flush the persistance URLs
- (void)updateQueues {
    pendingURLQueue = [VWOURLQueue queueWithFileURL:VWOFile.messageQueue];
    pendingURLQueue.delegate = self;
    failedURLQueue = [VWOURLQueue queueWithFileURL:VWOFile.failedMessageQueue];
    [failedURLQueue flush];
}

- (void)addGestureRecognizer {
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureRecognised:)];
    gesture.minimumPressDuration = 2;
    gesture.cancelsTouchesInView = NO;
    gesture.numberOfTouchesRequired = 5;

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication.sharedApplication.keyWindow addGestureRecognizer:gesture];
    });
}

- (void)longGestureRecognised:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        VWOLogInfo(@"Gesture recognized");
        [VWOSocketConnector launchWithAppKey:_appKey];
    }
}

- (void)timerAction {
    [pendingURLQueue flush];
}

- (void)trackConversion:(NSString *)goalIdentifier withValue:(NSNumber *)value {
    if (!_initialised) {
        VWOLogError(@"VWO must be launched first!");
        return;
    }

    if (VWOSocketConnector.isConnectedToBrowser) {
        VWOLogDebug(@"Marking goal on socket");
        [VWOSocketConnector goalTriggered:goalIdentifier withValue:value];
        return;
    }

    VWOLogDebug(@"Controller markConversionForGoal %@", goalIdentifier);

        //Check if the goal is already marked.
    for (VWOCampaign *campaign in _campaignList) {
        VWOGoal *matchedGoal = [campaign goalForIdentifier:goalIdentifier];
        if (matchedGoal) {

            if ([VWOUserDefaults isGoalMarked:matchedGoal inCampaign:campaign]) {
                VWOLogDebug(@"Goal '%@' already marked. Will not be marked again", matchedGoal);
                return;
            }
        }
    }

        // Mark goal(Goal can be present in multiple campaigns
    for (VWOCampaign *campaign in _campaignList) {
        VWOGoal *matchedGoal = [campaign goalForIdentifier:goalIdentifier];
        if (matchedGoal) {
            if ([VWOUserDefaults isTrackingUserForCampaign:campaign]) {
                [VWOUserDefaults markGoalConversion:matchedGoal inCampaign:campaign];
                NSURL *url = [_vwoURL forMarkingGoal:matchedGoal
                                          withValue:value
                                           campaign:campaign
                                            dateTime:NSDate.date];
                NSString *description = [NSString stringWithFormat:@"Goal %@", matchedGoal];
                [pendingURLQueue enqueue:url maxRetry:10 description:description];
            } else {
                VWOLogWarning(@"Goal %@ not tracked for %@ as user is not tracked", matchedGoal, campaign);
            }
        }
    }
}

- (id)variationForKey:(NSString *)key {
    if (!_initialised) {
        VWOLogWarning(@"variationForKey(%@) called before launching VWO", key);
        return nil;
    }

    if (VWOSocketConnector.isConnectedToBrowser) {
        if(key && _previewInfo != nil) {
            VWOLogInfo(@"Socket: got variation %@ for key %@", _previewInfo[key], key);
            return _previewInfo[key];
        }
        VWOLogInfo(@"Socket: got variation nil for key %@", key);
        return nil;
    }

    id finalVariation = nil;
    for (VWOCampaign *campaign in _campaignList) {
        id variation = [campaign variationForKey:key];
        BOOL isCampaignTracked = [VWOUserDefaults isTrackingUserForCampaign:campaign];

        //If variation Key is present in Campaign
        if (variation) {
            if (isCampaignTracked) {
                finalVariation = variation;
            } else {
                VWOSegmentEvaluator *evaluator = [VWOSegmentEvaluator makeEvaluator:_customVariables];
                BOOL canBePart = [evaluator canUserBePartOfCampaignForSegment:campaign.segmentObject];
                if (canBePart) {
                    finalVariation = variation;
                    [self trackUserForCampaign:campaign];
                }
            }
        }
    }
    if (finalVariation == [NSNull null]) {
        // finalVariation can be NSNull if Control is assigned to campaign
        return nil;
    }
    VWOLogDebug(@"Got variation %@ for key %@", finalVariation, key);
    return finalVariation;
}

- (nullable NSString *)variationNameForCampaignTestKey:(NSString *)campaignTestKey {
    if (!_initialised) {
        VWOLogWarning(@"variationNameForCampaignTestKey(%@) called before launching VWO", campaignTestKey);
        return nil;
    }
    
    id finalVariation = nil;
    for (VWOCampaign *campaign in _campaignList) {
        if ([campaign.testKey isEqualToString:campaignTestKey]) {
            id variation = campaign.variation.name;
            BOOL isCampaignTracked = [VWOUserDefaults isTrackingUserForCampaign:campaign];
            
                //If variation Key is present in Campaign
            if (isCampaignTracked) {
                finalVariation = variation;
            } else {
                VWOSegmentEvaluator *evaluator = [VWOSegmentEvaluator makeEvaluator:_customVariables];
                BOOL canBePart = [evaluator canUserBePartOfCampaignForSegment:campaign.segmentObject];
                if (canBePart) {
                    finalVariation = variation;
                    [self trackUserForCampaign:campaign];
                }
            }
        }
    }
    
    if (finalVariation == [NSNull null]) {
            // finalVariation can be NSNull if Control is assigned to campaign
        return nil;
    }
    
    VWOLogDebug(@"Got variation %@ for campaign %@", finalVariation, campaignTestKey);
    return finalVariation;
}

- (void)sendNotificationUserStartedTracking:(VWOCampaign *)campaign {
    VWOLogInfo(@"Controller: Sending notfication user started tracking %@", campaign);
    //Note: All values in campaignInfo dictionary must be in string format
    NSDictionary *campaignInfo = @{@"vwo_campaign_name"  : campaign.name.copy,
                                   @"vwo_campaign_id"    : [NSString stringWithFormat:@"%d", campaign.iD],
                                   @"vwo_variation_name" : campaign.variation.name.copy,
                                   @"vwo_variation_id"   : [NSString stringWithFormat:@"%d", campaign.variation.iD],
                                   };
    [NSNotificationCenter.defaultCenter postNotificationName:VWOUserStartedTrackingInCampaignNotification
                                                      object:nil
                                                    userInfo:campaignInfo];
}

- (void)trackUserForAllCampaignsOnLaunch:(VWOCampaignArray *)allCampaigns {
    VWOLogInfo(@"trackUserForAllCampaignsOnLaunch");
    VWOSegmentEvaluator *evaluator = [VWOSegmentEvaluator makeEvaluator:_customVariables];
    for (VWOCampaign *aCampaign in allCampaigns) {
        if (aCampaign.status == CampaignStatusExcluded) {
            [VWOUserDefaults setExcludedCampaign:aCampaign];
            continue;
        } else if (aCampaign.status == CampaignStatusRunning && aCampaign.trackUserOnLaunch) {
            if ([evaluator canUserBePartOfCampaignForSegment:aCampaign.segmentObject]) {
                [self trackUserForCampaign:aCampaign];
            } else {
                VWOLogDebug(@"Campaign %@ did not pass segmentation", aCampaign);
            }
        }
    }
}

- (void)trackUserForCampaign:(VWOCampaign *)campaign {
    NSParameterAssert(campaign);
    NSAssert(campaign.status == CampaignStatusRunning, @"Non running campaigns must not be tracked");

    if ([VWOUserDefaults isTrackingUserForCampaign:campaign]) {
        VWOLogDebug(@"Controller: Returning. Already tracking %@", campaign);
        return;
    }
    VWOLogDebug(@"Controller: trackUserForCampaign %@", campaign);

    [VWOUserDefaults trackUserForCampaign:campaign];

    //Send network request and notification only if the campaign is running

    NSURL *url = [_vwoURL forMakingUserPartOfCampaign:campaign dateTime:NSDate.date config: _vwoConfig];
    NSString *description = [NSString stringWithFormat:@"Track user %@ %@", campaign, campaign.variation];
    [pendingURLQueue enqueue:url maxRetry:10 description:description];

    [self sendNotificationUserStartedTracking:campaign];
}

- (void)pushCustomDimension:(nonnull NSString *)customDimensionKey withCustomDimensionValue:(nonnull NSString *)customDimensionValue {
    NSAssert(customDimensionKey.length != 0, @"customDimensionKey cannot be empty");
    NSAssert(customDimensionValue.length != 0, @"customDimensionValue cannot be empty");
    
    if (!_initialised) {
        VWOLogWarning(@"pushCustomDimension called before launching VWO");
        return;
    }
    
    NSURL *url = [_vwoURL forPushingCustomDimension:customDimensionKey withCustomDimensionValue:customDimensionValue dateTime:NSDate.date];
    NSString *description = [NSString stringWithFormat:@"Custom Dimension %@ %@", customDimensionKey, customDimensionValue];
    [pendingURLQueue enqueue:url maxRetry:10 description:description];
    
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)clearVWOData {
    [NSUserDefaults.standardUserDefaults removeObjectForKey:kUserDefaultsKey];
    
    [NSFileManager.defaultManager removeItemAtURL:VWOFile.campaignCache error:nil];
    [NSFileManager.defaultManager removeItemAtURL:VWOFile.messageQueue error:nil];
    [NSFileManager.defaultManager removeItemAtURL:VWOFile.failedMessageQueue error:nil];
}

#pragma mark - VWOURLQueueDelegate
- (void)retryCountExhaustedForURL:(NSURL *)url atFileURLPath:(NSURL *)fileURL {
    if ([pendingURLQueue.fileURL isEqual:fileURL]) {
        VWOLogWarning(@"Adding %@ to FAILURE QUEUE", url);
        [failedURLQueue enqueue:url maxRetry:5 description:nil];
    }
}

@end
