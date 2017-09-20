//
//  VWOAPIClient.m
//  VWO
//
//  Created by Wingify on 23/08/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VWOAPIClient.h"
#import "VWOModel.h"
#import "VWOAFHTTPRequestOperationManager.h"
#import "VWOAFHTTPRequestOperationManager+Synchronous.h"
#import "VWOSDK.h"
#import "VWODeviceInfo.h"
#import "NSDictionary+VWO.h"
#import "VWOLogger.h"
#import "VWOPersistantStore.h"
#import "VWOFile.h"
#import "VWOCampaign.h"

NSString * const kProtocol           = @"https://";
NSTimeInterval kTimerInterval        = 20.0;
NSUInteger kPendingMessagesThreshold = 3;
static NSString *kDomain             = @"dacdn.visualwebsiteoptimizer.com";

// For queuing of messages to be sent.
static NSInteger _transitId;
NSMutableArray *_pendingMessages;
NSMutableArray *_transittingMessages;
NSTimer *_timer;

@implementation VWOAPIClient

+ (instancetype)sharedInstance{
    static VWOAPIClient *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)initializeAndStartTimer {
    _transitId = (NSInteger) NSDate.timeIntervalSinceReferenceDate;
    _pendingMessages = [NSMutableArray new];
    if ([NSFileManager.defaultManager fileExistsAtPath:VWOFile.messages.path]) {
        _pendingMessages = [NSMutableArray arrayWithContentsOfURL:VWOFile.messages];
    }
    _transittingMessages = [NSMutableArray array];
    
    // fire first call early on to clear any pending data from last time the application was run.
    [self startTimer];
}

- (void) startTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval
                                              target:VWOAPIClient.sharedInstance
                                            selector:@selector(sendAllPendingMessages)
                                            userInfo:nil
                                             repeats:YES];
    [_timer fire];//to start immediately
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void) fetchCampaignsAsynchronouslyOnSuccess:(void(^)(id))successBlock
                failure:(void(^)(NSError *))failureBlock {
    NSString *url                   = [NSString stringWithFormat:@"%@%@/mobile", kProtocol,kDomain];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"a"]                = VWOSDK.accountID;
    parameters[@"v"]                = VWOSDK.version;
    parameters[@"i"]                = VWOSDK.appKey;
    parameters[@"dt"]               = VWODeviceInfo.platformName;
    parameters[@"os"]               = UIDevice.currentDevice.systemVersion;
    parameters[@"u"]                = VWOPersistantStore.UUID;
    parameters[@"r"]                = @(((double)arc4random_uniform(0xffffffff))/(0xffffffff - 1));
    parameters[@"k"]                = VWOPersistantStore.campaignVariationPairs.toString;

    VWOAFHTTPRequestOperationManager *manager = [VWOAFHTTPRequestOperationManager manager];
    VWOLogDebug(@"Asynchronously Downloading Campaigns");
    [manager GET:url parameters:parameters success:^(VWOAFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(responseObject);
        }
    } failure:^(VWOAFHTTPRequestOperation *operation, NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

- (id)fetchCampaignsSynchronouslyForTimeout:(NSTimeInterval)timeout
                                      error:(NSError *__autoreleasing *)error {
    NSString *url                   = [NSString stringWithFormat:@"%@%@/mobile", kProtocol,kDomain];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"a"]                = VWOSDK.accountID;
    parameters[@"v"]                = VWOSDK.version;
    parameters[@"i"]                = VWOSDK.appKey;
    parameters[@"dt"]               = VWODeviceInfo.platformName;
    parameters[@"os"]               = UIDevice.currentDevice.systemVersion;
    parameters[@"u"]                = VWOPersistantStore.UUID;
    parameters[@"r"]                = @(((double)arc4random_uniform(0xffffffff))/(0xffffffff - 1));
    parameters[@"k"]                = VWOPersistantStore.campaignVariationPairs.toString;

    VWOAFHTTPRequestOperationManager *manager = [VWOAFHTTPRequestOperationManager manager];
    VWOLogDebug(@"Synchronously Downloading Campaigns");
    id data = [manager synchronousGET:url parameters:parameters timeout:timeout error:error];
    return data;
}

- (void)makeUserPartOfCampaign:(VWOCampaign *)campaign {
    NSString *variationID = [NSString stringWithFormat:@"%d", campaign.variation.iD];
    [self callMethod:@"render" withParameters:@{@"expId": @(campaign.iD), @"varId": variationID}];
}

- (void) markConversionForGoalId:(NSInteger)goalId
                    experimentId:(NSInteger)experimentId
                     variationId:(NSInteger)variationId
                         revenue:(NSNumber *)revenue {

    NSMutableDictionary *params = [@{@"goalId": @(goalId), @"expId":@(experimentId), @"varId": @(variationId)} mutableCopy];
    params[@"revenue"] = revenue;

    [self callMethod:@"goal" withParameters:params];
}

- (void)callMethod:(NSString *)method withParameters:(NSDictionary *)params{
    NSString *transitId   = [VWOAPIClient allocateTransitId];
    NSNumber *timestamp   = @([[NSDate date] timeIntervalSince1970]);
    NSDictionary *message = @{@"method" : method, @"params" : params, @"timestamp" : timestamp, @"id" : transitId};

    [_pendingMessages addObject:message];
    [VWOModel.sharedInstance saveMessages:[_pendingMessages copy]];
    if(_pendingMessages.count >= kPendingMessagesThreshold){
        [self sendAllPendingMessages];
    }
}

- (void)sendMessage:(NSDictionary*)message
          onSuccess:(void (^)(NSString *))successBlock
          onFailure:(void (^)(NSError *, NSString*))failureBlock {
    
    NSString *transitId  = message[@"id"];
    NSDictionary *params = message[@"params"];
    BOOL isRender        = [message[@"method"] isEqualToString:@"render"];
    NSString *appVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];

    NSString *url = [NSString stringWithFormat:@"%@%@/%@.gif", kProtocol, kDomain, isRender ? @"l"  :@"c"];

    NSDictionary *extraParams = @{@"lt" : message[@"timestamp"],
                                  @"v"  : VWOSDK.version,
                                  @"i"  : VWOSDK.appKey,
                                  @"av" : appVersion,
                                  @"dt" : VWODeviceInfo.platformName,
                                  @"os" : UIDevice.currentDevice.systemVersion
                                  };
        
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"experiment_id"] = params[@"expId"];
    parameters[@"account_id"]    = VWOSDK.accountID;
    parameters[@"combination"]   = params[@"varId"];
    parameters[@"u"]             = VWOPersistantStore.UUID;
    parameters[@"s"]             = @(VWOPersistantStore.sessionCount);
    parameters[@"random"]        = @(((double)arc4random_uniform(0xffffffff))/(0xffffffff - 1));
    parameters[@"ed"]            = [extraParams toString];

    if(isRender == NO) {
        parameters[@"goal_id"] = params[@"goalId"];
        if(params[@"revenue"]) {
            parameters[@"r"] = params[@"revenue"];
        }
    }
    
    VWOAFHTTPRequestOperationManager *manager = [VWOAFHTTPRequestOperationManager manager];

    [manager GET:url parameters:parameters success:^(VWOAFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(transitId);
        }
    } failure:^(VWOAFHTTPRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode == 200) {
            VWOLogDebug(@"Network success %@", operation.response.URL.absoluteString);
            if (successBlock) {
                successBlock(transitId);
            }
        } else {
            VWOLogWarning(@"Network failed [%@]", error.localizedDescription);
            if (failureBlock) {
                failureBlock(error, transitId);
            }
        }
    }];
}

- (void)sendAllPendingMessages {
    for (NSDictionary *message in _pendingMessages) {

        if ([_transittingMessages containsObject:message[@"id"]]) {
            // message is already being sent
            continue;
        }

        // add this message to transitting messages list
        [_transittingMessages addObject:[message[@"id"] copy]];

        [self sendMessage:message onSuccess:^(NSString *transitId) {
            for(int i = 0; i < _pendingMessages.count; i++){
                if([transitId isEqualToString:_pendingMessages[i][@"id"]]){
                    
                    // we are deleting from the array we are iterating over. This is generally not safe.
                    // but here it is ok as we are breaking from iteration right after deletion.
                    [_pendingMessages removeObjectAtIndex:i];
                    [_transittingMessages removeObjectIdenticalTo:transitId];
                    [VWOModel.sharedInstance saveMessages:[_pendingMessages copy]];
                    break;
                }
            }
        } onFailure:^(NSError *error, NSString *transitId) {
            [_transittingMessages removeObjectIdenticalTo:transitId];
        }];
    }
}

-(void)dealloc{
    [_timer invalidate];
}

+ (NSString *)allocateTransitId{
    return [@(++_transitId) stringValue];
}

@end
