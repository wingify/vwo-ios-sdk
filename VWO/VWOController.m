
#import "VWOController.h"
#import "VWOSocketConnector.h"
#import "VWOLogger.h"
#import "VWOCampaign.h"
#import "VWOURLQueue.h"
#import "VWOFilePath.h"
#import "VWOURL.h"
#import "VWODevice.h"
#import "VWOUserDefaults.h"
#import <UIKit/UIKit.h>
#import "VWOConfig.h"
#import "VWOCampaignCache.h"
#import "NSURLSession+Synchronous.h"
#import "VWOSegmentEvaluator.h"

static NSTimeInterval kMessageQueueFlushInterval  = 10;
//static NSString *const kUserDefaultsKey = @"vwo.09cde70ba7a94aff9d843b1b846a79a7";
static NSString *const kUserDefaultsKey = @"vwo.09cde70ba7a94aff9d843b1b846a79a8";

@interface VWOController() <VWOURLQueueDelegate>
@property NSArray<VWOCampaign *> *campaignList;
@property VWOURL *vwoURL;
@property VWOCampaignCache *campaignFetcher;
@property VWOSegmentEvaluator *evaluator;


/// This flag is set when first request to variationForKey or trackConversion is sent
@property BOOL vwoUsageStarted;
@end

@implementation VWOController {
    VWOURLQueue *pendingURLQueue;
    
    //URLS that are not successfully sent. Are loaded in failureQueue
    //Failure queue is flushed only on app launch
    VWOURLQueue *failedURLQueue;
    NSTimer *messageQueueFlushtimer;
    dispatch_queue_t _vwoQueue;
}

- (id)init {
    if (self = [super init]) {
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
            withCallback:(void(^)(void))completionBlock
                 failure:(void(^)(NSString *error))failure {

    if (_initialised) {
        VWOLogWarning(@"VWO must not be initialised more than once");
        return;
    }

    VWOLogInfo(@"Initializing VWO with API Key %@", apiKey);

    NSAssert([apiKey componentsSeparatedByString:@"-"].count == 2, @"Invalid API key");
    NSAssert([apiKey componentsSeparatedByString:@"-"].firstObject.length == 32, @"Invalid API key");

    NSArray<NSString *> *splitKey = [apiKey componentsSeparatedByString:@"-"];
    _appKey    = splitKey[0];
    _accountID = splitKey[1];

    [VWOUserDefaults setDefaultsKey:kUserDefaultsKey];
    VWOUserDefaults.sessionCount += 1;

    VWOConfig *config = configNullable != nil ? configNullable : VWOConfig.defaultConfig;

    if (config.optOut) {
        [self handleOptOutwithCompletion:completionBlock]; return;
    }
    if (config.disablePreview == NO) { [self launchSocketOrAddGesture]; }

    pendingURLQueue = [VWOURLQueue queueWithFileURL:VWOFilePath.messageQueue];
    pendingURLQueue.delegate = self;
    failedURLQueue = [VWOURLQueue queueWithFileURL:VWOFilePath.failedMessageQueue];
    [failedURLQueue flush];//Flushed only on launch

    _vwoURL = [VWOURL urlWithAppKey:_appKey accountID:_accountID];
    _evaluator = [[VWOSegmentEvaluator alloc] initWithCustomVariables:config.customVariables];

    [VWOCampaignCache writeFromSettingsFile:@"vwo_settings" to:VWOFilePath.campaignCache];

    if (config.forceReloadCampaingsOnLaunch) {
        NSString *errorString;
        [VWOCampaignCache writeFromNetworkResponse:[_vwoURL forFetchingCampaigns]
                                           timeout:config.timeout
                                                to:VWOFilePath.campaignCache
                                             error:&errorString];
        if (errorString) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                failure(errorString);
            });
            return;
        }
        [self synchronizeCampaignsInfo:_campaignList];
    } else { [self loadCampaignListInBackground]; }


    [self startTimer];
    _initialised = true;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        completionBlock();
    });

}

/// Reads all campaigns from cache, evalutes them and returns the campaigns that pass evaluation
/// Error is generated when campaign cache is empty
- (nullable NSArray<VWOCampaign *>*)getEvaluatedCampaignsFromCache:(NSString **)errorString {
    NSArray<VWOCampaign *>* campaignList = [VWOCampaignCache getCampaingsFromCache:VWOFilePath.campaignCache error:&errorString];
    if (errorString || campaignList == nil) return nil;

    NSMutableArray<VWOCampaign *> *newCampaignList = [NSMutableArray new];
    for (VWOCampaign *aCampaign in campaignList) {
        if ([evaluator canUserBePartOfCampaignForSegment:aCampaign.segmentObject]) {
            [newCampaignList addObject:aCampaign];
        } else {
            VWOLogDebug(@"Campaign %@ did not pass segmentation", aCampaign);
        }
    }
    return newCampaignList;
}

/**
 Loads campaings from network and writes to cache.

 Loads campaigns from cache and updates the _campaignList

 Store campaign info VWOUserDefaults

 @note When forceReloadCampaingsOnLaunch is false campaings would be loaded in background
 */
- (void)loadCampaignListInBackground {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [VWOCampaignCache writeFromNetworkResponse:[_vwoURL forFetchingCampaigns]
                                           timeout:60
                                                to:VWOFilePath.campaignCache
                                             error:nil];
        NSError *error;
        NSArray<VWOCampaign *> *newCampaignList = [self getEvaluatedCampaignsFromCache:&error];
        if (!_vwoUsageStarted && newCampaignList != nil && error == nil) {
            _campaignList = newCampaignList;
            [self synchronizeCampaignsInfo:_campaignList];
        }
    });
}

/// Store all the campaign realted info  like isUserTracked, isUserExcluded in VWOUserDefaults
- (void)synchronizeCampaignsInfo:(VWOCampaignArray *)campaignList {
    NSParameterAssert(campaignList);
    for (VWOCampaign *aCampaign in campaignList) {
        if (![VWOUserDefaults isCampaignExcluded:aCampaign] &&
            ![VWOUserDefaults isUserTrackedForCampaign:aCampaign]) {
            int random = arc4random_uniform(101);
            if (random <= percent) {
                [self trackUserForCampaign:aCampaign];
            } else {
                [VWOUserDefaults setCampaignExcluded:aCampaign];
            }
        }
    }
}

- (void)handleOptOutwithCompletion:(void(^)(void))completionBlock {
    VWOLogWarning(@"Cannot launch. VWO opted out");
    [NSUserDefaults.standardUserDefaults removeObjectForKey:kUserDefaultsKey];

    [NSFileManager.defaultManager removeItemAtURL:VWOFilePath.campaignCache error:nil];
    [NSFileManager.defaultManager removeItemAtURL:VWOFilePath.messageQueue error:nil];
    [NSFileManager.defaultManager removeItemAtURL:VWOFilePath.failedMessageQueue error:nil];

    if (completionBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completionBlock();
        });
    }
}

/// If phone is connected to machine launch socket else add Gesture Recognizer
- (void)launchSocketOrAddGesture {
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

    /// set in VWOUserDefaults, add in pending queue & send notification
- (void)trackUserForCampaign:(VWOCampaign *)campaign {
    NSParameterAssert(campaign);

    if (![VWOUserDefaults isUserTrackedForCampaign:campaign]) {
        VWOLogDebug(@"Track User For Campaign %@", campaign);

        [VWOUserDefaults trackUserForCampaign:campaign];

        NSURL *url = [_vwoURL forMakingUserPartOfCampaign:campaign date:NSDate.date];
        NSString *description = [NSString stringWithFormat:@"Track user %@ %@", campaign, campaign.variation];
        [pendingURLQueue enqueue:url maxRetry:10 description:description];

        [self sendNotificationUserStartedTracking:campaign];
    }
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

- (void)startTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->messageQueueFlushtimer =
        [NSTimer scheduledTimerWithTimeInterval:kMessageQueueFlushInterval
                                         target:self
                                       selector:@selector(timerAction)
                                       userInfo:nil repeats:YES];
    });
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

    _vwoUsageStarted = YES;

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
            if ([VWOUserDefaults isUserTrackedForCampaign:campaign]) {
                [VWOUserDefaults markGoalConversion:matchedGoal inCampaign:campaign];
                NSURL *url = [_vwoURL forMarkingGoal:matchedGoal
                                           withValue:value
                                            campaign:campaign
                                                date:NSDate.date];
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

    _vwoUsageStarted = YES;
    id finalValue = nil;
    for (VWOCampaign *campaign in _campaignList) {
        NSNumber *variationID = [VWOUserDefaults selectedVariationForCampaign:campaign];
        VWOVariation *variation = [campaign variationForID:variationID];
        id value = [variation valueOfKey:key];
        if (value != nil) {
            finalValue = value;
            if (campaign.trackUserOnLaunch == false) [self trackUserForCampaign:campaign];
        }
    }
    if (finalValue == [NSNull null]) {
        return nil; // finalVariation can be NSNull if Control is assigned to campaign
    }
    VWOLogDebug(@"Got variation %@ for key %@", finalValue, key);
    return finalValue;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - VWOURLQueueDelegate
- (void)retryCountExhaustedForURL:(NSURL *)url atFileURLPath:(NSURL *)fileURL {
    if ([pendingURLQueue.fileURL isEqual:fileURL]) {
        VWOLogWarning(@"Adding %@ to FAILURE QUEUE", url);
        [failedURLQueue enqueue:url maxRetry:5 description:nil];
    }
}

@end
