//
//  VWOCampaignFetcher.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 30/03/18.
//  Copyright © 2018-2022 vwo. All rights reserved.
//

#import "VWOCampaignFetcher.h"
#import "VWOLogger.h"
#import "VWOFile.h"
#import "NSURLSession+Synchronous.h"
#import "VWOSegmentEvaluator.h"
#import "VWOCampaign.h"

static NSTimeInterval const defaultFetchCampaignsTimeout = 60;

@implementation VWOCampaignFetcher

/**
 Fetch campaigns from network
 If campaigns not available the returns campaigns from cache
 @note completionblock and failureblocks are invoked only in this method
 @return Array of campaigns. nil if network returns 400. nil if campaign list not available on network and cache
 */
+ (nullable VWOCampaignArray *)getCampaignsWithTimeout:(NSNumber *)timeout
                                                         url:(NSURL *)url
                                                withCallback:(void(^)(void))completionBlock
                                                     failure:(void(^)(NSString *error))failureBlock {
    VWOLogDebug(@"Fetching campaigns");
    NSString *errorString;

    NSData *data = [self getCampaignsFromNetworkWithTimeout:timeout url:url onFailure:&errorString];

    if (errorString != nil) {
        VWOLogError(errorString);
        if (failureBlock) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                failureBlock(errorString);
            });
        }
        return nil;
    }

    if (data == nil) {
        data = [NSData dataWithContentsOfURL:VWOFile.campaignCache];
        if (data == nil) {
            VWOLogWarning(@"No campaigns available. No cache available");
            if (failureBlock) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    failureBlock(errorString);
                });
            }
            return nil;
        }
        VWOLogInfo(@"Loading from Cache");
    } else {
        BOOL isIt = [data writeToURL:VWOFile.campaignCache atomically:YES];
        VWOLogDebug(@"Cache updated: %@", isIt ? @"success" : @"failed");
    }

    NSError *jsonerror;
    NSArray<NSDictionary *> *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonerror];
    VWOLogDebug(@"%@", jsonArray);

    VWOCampaignArray *allCampaigns = [self campaignsFromJSON:jsonArray];

    if (completionBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completionBlock();
        });
    }
    return  allCampaigns;
}

+ (nullable NSData *)getCampaignsFromNetworkWithTimeout:(NSNumber *)timeout
                                                    url:(NSURL *)url
                                              onFailure:(NSString **)errorString {

    NSTimeInterval timeOutInterval = (timeout == nil) ? defaultFetchCampaignsTimeout : timeout.doubleValue;
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:timeOutInterval];

    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLSession.sharedSession sendSynchronousDataTaskWithRequest:request
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

+ (VWOCampaignArray *)campaignsFromJSON:(NSArray<NSDictionary *> *)jsonArray {
    NSMutableArray<VWOCampaign *> *newCampaignList = [NSMutableArray new];
    for (NSDictionary *campaignDict in jsonArray) {
        VWOCampaign *aCampaign = [[VWOCampaign alloc] initWithDictionary:campaignDict];
        if (aCampaign) [newCampaignList addObject:aCampaign];
    }
    return newCampaignList;
}

@end
