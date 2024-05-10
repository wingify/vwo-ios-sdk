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
#import "VWOUserDefaults.h"
#import "VWOConstants.h"

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
        if (ConstAPIVersion != VWOUserDefaults.PreviousAPIversion) {
            VWOLogWarning(@"No campaigns available. No cache available for current AppVersion");
            if (failureBlock) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    failureBlock(errorString);
                });
            }
            return nil;
        }
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
        [VWOUserDefaults updatePreviousAPIversion:(NSString *)ConstAPIVersion];
        BOOL isIt = [data writeToURL:VWOFile.campaignCache atomically:YES];
        VWOLogDebug(@"Cache updated: %@", isIt ? @"success" : @"failed");
    }
    
    NSError *jsonerror;
    //handle NSDict nd NSArray comparison
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonerror];
    VWOLogDebug(@"%@", jsonDict);
    
    if (![jsonDict isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Expected a dictionary but received a %@", NSStringFromClass([jsonDict class]));
        if (failureBlock) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                failureBlock(errorString);
            });
        }
        return nil;
    }
    
    [self checkForIsEventArchEnabledFlag:jsonDict];
    VWOCampaignArray *allCampaigns = [self EUCheckAndDataFetching:jsonDict];
    
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

+ (VWOCampaignArray *)EUCheckAndDataFetching:(NSDictionary *) jsonDict{
    NSMutableArray<VWOCampaign *> *newCampaignList = [NSMutableArray new];
    NSLog(@"%@", [jsonDict objectForKey: ConstCampaigns] );
    NSArray<NSDictionary *> *campaignArray = [jsonDict objectForKey: ConstCampaigns];
    VWOLogDebug(@"%@", campaignArray);
    VWOCampaignArray *allCampaigns = [self campaignsFromJSON:campaignArray];
    [newCampaignList addObjectsFromArray:allCampaigns];
    
    //check for EU client or not
    if([jsonDict objectForKey: ConstCollectionPrefix] != NULL){
        NSString *collectionPrefix = [NSString stringWithFormat: @"/%@", [jsonDict objectForKey: ConstCollectionPrefix]];
        [VWOUserDefaults updateCollectionPrefix: collectionPrefix];
    }else{
        [VWOUserDefaults updateCollectionPrefix: @""];
    }
    
    //checking for availablility of groups in response
    if([jsonDict objectForKey: ConstGroups] != NULL && [jsonDict objectForKey: ConstCampaignGroups] != NULL){
        NSDictionary *groupDict = @{ConstGroups:[jsonDict objectForKey:ConstGroups], ConstCampaignGroups:[jsonDict objectForKey:ConstCampaignGroups] ,ConstType: ConstGroups};
        VWOCampaign *aCampaign = [[VWOCampaign alloc] setGroups:groupDict];
        if (aCampaign) [newCampaignList addObject:aCampaign];
    }
    
    return newCampaignList;
}

+(void)checkForIsEventArchEnabledFlag:(NSDictionary *)jsonDict{
    BOOL isEventArchEnabledFlag = [[jsonDict objectForKey:ConstIsEventArchEnabled] boolValue];
    BOOL isMobile360EnabledFlag = [[jsonDict objectForKey:ConstIsMobile360Enabled] boolValue];
    if(isEventArchEnabledFlag == YES && isMobile360EnabledFlag == YES){
        [VWOUserDefaults updateIsEventArchEnabled: ConstEventArchEnabled];
    }
    else{
        [VWOUserDefaults updateIsEventArchEnabled: ConstEventArchDisabled];
    }
}

@end
