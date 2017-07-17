//
//  VAOAPIClient.m
//  VAO
//
//  Created by Wingify on 23/08/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VAOAPIClient.h"
#import "VAOModel.h"
#import <sys/utsname.h>
#import "VAOAFHTTPRequestOperationManager.h"
#import "VAOAFHTTPRequestOperationManager+Synchronous.h"
#import "VAOSDKInfo.h"
#import "VAODeviceInfo.h"
#import "NSDictionary+VWO.h"
#import "VAOLogger.h"
#import "VAOPersistantStore.h"

NSString * const kProtocol = @"http://";
NSTimeInterval kTimerInterval = 20.0;
NSUInteger kPendingMessagesThreshold = 3;
static NSString *kDomain = @"dacdn.vwo.com";

// For queqeing of messages to be sent.
static NSInteger _transitId;
NSMutableArray *_pendingMessages;
NSMutableArray *_transittingMessages;
NSTimer *_timer;

@implementation VAOAPIClient

+ (instancetype)sharedInstance{
    static VAOAPIClient *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)initializeAndStartTimer {
    _transitId = (NSInteger) [[NSDate date] timeIntervalSinceReferenceDate];
    _pendingMessages = [NSMutableArray arrayWithArray:[[VAOModel sharedInstance] loadMessagesFromFile]];
    _transittingMessages = [NSMutableArray array];
    
    // fire first call early on to clear any pending data from last time the application was run.
    [self startTimer];
}

- (void) startTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval
                                              target:[VAOAPIClient sharedInstance]
                                            selector:@selector(sendAllPendingMessages)
                                            userInfo:nil
                                             repeats:YES];
    [_timer fire];//to start immediately
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

// For App
- (void) pullABDataAsynchronously:(BOOL)isAsync
                         success:(void(^)(id))successBlock
                         failure:(void(^)(NSError *))failureBlock {
    
    NSString *url = [NSString stringWithFormat:@"%@%@/mobile", kProtocol,kDomain];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"a"] = VAOSDKInfo.accountID;
    parameters[@"v"] = [VAOSDKInfo sdkVersion],
    parameters[@"i"] = VAOSDKInfo.appKey;
    parameters[@"dt"] = [VAODeviceInfo deviceType];
    parameters[@"os"] = [[UIDevice currentDevice] systemVersion];
    parameters[@"u"] =  VAOPersistantStore.UUID;
    parameters[@"r"] =  @(((double)arc4random_uniform(0xffffffff))/(0xffffffff - 1));
    parameters[@"k"] =  [[VAOPersistantStore campaignVariationPairs] toString];
    
    VAOAFHTTPRequestOperationManager *manager = [VAOAFHTTPRequestOperationManager manager];
    if (isAsync) {
        [VAOLogger info:@"ASynchronously Downloading Campaigns"];
        [manager GET:url parameters:parameters success:^(VAOAFHTTPRequestOperation *operation, id responseObject) {
            if (successBlock) {
                successBlock(responseObject);
            }
        } failure:^(VAOAFHTTPRequestOperation *operation, NSError *error) {
            if (failureBlock) {
                failureBlock(error);
            }
        }];
    }
    else {
        [VAOLogger info:@"Synchronously Downloading Campaigns"];
        NSError *error;
        id data = [manager syncGET:url parameters:parameters operation:NULL error:&error];
        if (successBlock && !error) {
            successBlock(data);
        } else if(failureBlock){
            failureBlock(error);
        }
    }
}

- (void)makeUserPartOfCampaign:(NSInteger)campaignID forVariation:(NSString *)variationId {
    [self callMethod:@"render" withParameters:@{@"expId": @(campaignID), @"varId": variationId}];
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
    NSString *transitId = [VAOAPIClient allocateTransitId];
    NSNumber *timestamp = @([[NSDate date] timeIntervalSince1970]);
    NSDictionary *message = @{@"method":method, @"params":params, @"timestamp":timestamp, @"id":transitId};
    [_pendingMessages addObject:message];
    [[VAOModel sharedInstance] saveMessages:[_pendingMessages copy]];
    if(_pendingMessages.count >= kPendingMessagesThreshold){
        [self sendAllPendingMessages];
    }
}

- (void)sendMessage:(NSDictionary*)message
          onSuccess:(void (^)(NSString *))successBlock
          onFailure:(void (^)(NSError *, NSString*))failureBlock {
    
    NSString *transitId = message[@"id"];
    NSDictionary *params = message[@"params"];
    BOOL isRender = [message[@"method"] isEqualToString:@"render"];
    NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];

    NSString *url = [NSString stringWithFormat:@"%@%@/%@.gif", kProtocol, kDomain, isRender ? @"l"  :@"c"];

    NSDictionary *extraParams = @{@"lt": message[@"timestamp"],
                                  @"v": [VAOSDKInfo sdkVersion],
                                  @"i": VAOSDKInfo.appKey,
                                  @"av": appVersion,
                                  @"dt": [VAODeviceInfo deviceType],
                                  @"os": [[UIDevice currentDevice] systemVersion]
                                  };
        
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"experiment_id"] = params[@"expId"];
    parameters[@"account_id"] = VAOSDKInfo.accountID;
    parameters[@"combination"] = params[@"varId"];
    parameters[@"u"] =  VAOPersistantStore.UUID;
    parameters[@"s"] = @([VAOPersistantStore sessionCount]);
    parameters[@"random"] = @(((double)arc4random_uniform(0xffffffff))/(0xffffffff - 1));
    parameters[@"ed"] = [extraParams toString];
    
    if(isRender == NO) {
        parameters[@"goal_id"] = params[@"goalId"];
        if(params[@"revenue"]) {
            parameters[@"r"] = params[@"revenue"];
        }
    }
    
    VAOAFHTTPRequestOperationManager *manager = [VAOAFHTTPRequestOperationManager manager];

    [manager GET:url parameters:parameters success:^(VAOAFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(transitId);
        }
    } failure:^(VAOAFHTTPRequestOperation *operation, NSError *error) {
        [VAOLogger error:error];
        if (operation.response.statusCode == 200) {
            if (successBlock) {
                successBlock(transitId);
            }
        } else {
            if (failureBlock) {
                failureBlock(error, transitId);
            }
        }

    }];
}

/**
 * Timer operation to send messages to VAO server.
 */
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
                    [[VAOModel sharedInstance] saveMessages:[_pendingMessages copy]];
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
