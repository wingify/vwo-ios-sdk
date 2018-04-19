    //
    //  VWOCampaignFetcher.m
    //  VWO
    //
    //  Created by Kaunteya Suryawanshi on 30/03/18.
    //  Copyright © 2018 vwo. All rights reserved.
    //

#import "VWOCampaignFetcher.h"
#import "VWOLogger.h"
#import "VWOFile.h"
#import "NSURLSession+Synchronous.h"
#import "VWOSegmentEvaluator.h"
#import "VWOCampaign.h"
#import "VWOUserDefaults.h"

static NSTimeInterval const defaultFetchCampaignsTimeout = 60;

@interface VWOCampaignFetcher()
@property BOOL settingsFilePresent;
@property NSURLRequest *urlRequest;
@end

@implementation VWOCampaignFetcher

- (instancetype)initWithURL:(NSURL *)url
                    timeout:(NSNumber *)timeout
            customVariables:(nullable NSDictionary *)customVariables {
    self = [super init];
    if (self) {
        NSTimeInterval requestTimeout = timeout ? timeout.doubleValue : defaultFetchCampaignsTimeout;
        _urlRequest = [NSURLRequest requestWithURL:url
                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                   timeoutInterval:requestTimeout];

        _evaluator = [[VWOSegmentEvaluator alloc] initWithCustomVariables:customVariables];
    }
    return self;
}

- (void)updateCacheOnceFromSettingsFileNamed:(NSString *)fileName {
    if ([NSFileManager.defaultManager fileExistsAtPath:VWOFile.campaignCache.path]) {
        return;
    }
    NSURL *settingsFileURL = [NSBundle.mainBundle URLForResource:fileName withExtension:@"json"];
    _settingsFilePresent = settingsFileURL != nil;
    NSData *data = [NSData dataWithContentsOfURL:settingsFileURL];
    BOOL isIt = [data writeToURL:VWOFile.campaignCache atomically:YES];
    VWOLogDebug(@"Settings copied to cache: %@", isIt ? @"success" : @"failed");
}

/**
 If campaigns not available the returns campaigns from cache
 @note completionblock and failureblocks are invoked only in this method
 @return Array of campaigns. nil if network returns 400. nil if campaign list not available on network and cache
 */
- (nullable VWOCampaignArray *)fetchWithCallback:(void(^)(void))completion
                                         failure:(void(^)(NSString *error))failure {

    NSData *settingsData;
    if (_settingsFilePresent) {
        settingsData = [NSData dataWithContentsOfURL:VWOFile.campaignCache];
    } else {
        NSString *errorString;
        settingsData = [self getCampaignsFromNetwork:&errorString];
        if (errorString) {
            VWOLogError(errorString);
            [self invokeFailure:failure error:errorString];
            return nil;
        }
        if (settingsData == nil) {
            settingsData = [NSData dataWithContentsOfURL:VWOFile.campaignCache];
            if (settingsData == nil) {
                VWOLogWarning(@"No campaigns available. No cache available");
                [self invokeFailure:failure error:@"Campaigns not available"];
                return nil;
            }
            VWOLogInfo(@"Loading campaigns from Cache");
        } else {
            BOOL isIt = [settingsData writeToURL:VWOFile.campaignCache atomically:YES];
            VWOLogDebug(@"Cache updated: %@", isIt ? @"success" : @"failed");
        }
    }

    NSError *jsonerror;
    NSArray<NSDictionary *> *jsonArray = [NSJSONSerialization JSONObjectWithData:settingsData options:0 error:&jsonerror];
    VWOLogDebug(@"%@", jsonArray);

    VWOCampaignArray *allCampaigns = [self campaignsFromJSON:jsonArray];
    VWOCampaignArray *evaluatedCampaigns = [self segmentEvaluated:allCampaigns evaluator:_evaluator];
    [self invokeCompletion:completion];
    return  evaluatedCampaigns;
}

- (nullable NSData *)getCampaignsFromNetwork:(NSString **)errorString {
    VWOLogDebug(@"Fetching settings from network");

    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLSession.sharedSession sendSynchronousDataTaskWithRequest:_urlRequest
                                                                returningResponse:&response
                                                                            error:&error];

    if (data == nil) { return nil; }

    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    if(statusCode >= 400 && statusCode <= 499) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        VWOLogError(@"Client side error %@", json[@"message"]);
        *errorString = json[@"message"];
        return nil;
    }
    if (statusCode >= 500 && statusCode <=599) { return nil; }
    return data;
}

- (VWOCampaignArray *)campaignsFromJSON:(NSArray<NSDictionary *> *)jsonArray {
    NSMutableArray<VWOCampaign *> *newCampaignList = [NSMutableArray new];

    for (NSDictionary *campaignDict in jsonArray) {
        NSNumber *variationID = nil;
        if (campaignDict[@"id"] != nil) {
            variationID = [VWOUserDefaults selectedVariationForCampaignID:[campaignDict[@"id"] intValue]];
        }
        VWOCampaign *aCampaign = [[VWOCampaign alloc] initWithDictionary:campaignDict selectVariation:variationID];
        if (aCampaign) { [newCampaignList addObject:aCampaign]; }
    }
    return newCampaignList;
}

- (VWOCampaignArray *)segmentEvaluated:(VWOCampaignArray *)allCampaigns
                             evaluator:(VWOSegmentEvaluator *)evaluator {
    NSMutableArray<VWOCampaign *> *newCampaignList = [NSMutableArray new];
    for (VWOCampaign *aCampaign in allCampaigns) {
        if ([evaluator canUserBePartOfCampaignForSegment:aCampaign.segmentObject]) {
            [newCampaignList addObject:aCampaign];
        } else {
            VWOLogDebug(@"Campaign %@ did not pass segmentation", aCampaign);
        }
    }
    return newCampaignList;
}

- (void)invokeFailure:(nullable void(^)(NSString *error))failure error:(NSString *)error {
    if (failure) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            failure(error);
        });
    }
}

- (void)invokeCompletion:(void(^)(void))completionBlock {
    if (completionBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completionBlock();
        });
    }
}

@end
