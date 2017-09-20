//
//  VWOClient.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 08/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "VWOClient.h"

#import "VWOController.h"
#import "VWOSocketClient.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import "VWOSDK.h"
#import "VWODeviceInfo.h"

static VWOLogLevel kLogLevel = VWOLogLevelError;
NSString * const VWOUserStartedTrackingInCampaignNotification = @"VWOUserStartedTrackingInCampaignNotification";

@implementation VWO

+ (VWOLogLevel)logLevel {
    return kLogLevel;
}

+ (void)setLogLevel:(VWOLogLevel)level {
    kLogLevel = level;
}

+ (void)setUpForKey:(NSString *) key
            isAsync:(BOOL) async
            timeout:(NSTimeInterval)timeout
         completion:(void (^)(void))completionBlock
            failure:(void (^)(void))failureBlock {
    static VWO *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{

        instance = [[self alloc] init];
        [VWOSDK setAppKeyID:key];

        if (VWODeviceInfo.isAttachedToDebugger) {
            [[VWOSocketClient sharedInstance] launch];
        }
        VWOLogInfo(@"Initializing VWO");
        VWOLogDebug(@"Key: %@", key);
        [VWOController.sharedInstance initializeAsynchronously:async timeout:timeout withCallback:completionBlock failure:failureBlock];
    });
}

+ (void)launchForAPIKey:(NSString *) apiKey {
    NSParameterAssert(apiKey);
    [self setUpForKey:apiKey isAsync:YES timeout:0 completion:nil failure:nil];
}

+ (void)launchForAPIKey:(NSString *) apiKey completion:(void(^)(void))completion {
    NSParameterAssert(apiKey);
    [self setUpForKey:apiKey isAsync:YES timeout:0 completion:completion failure:nil];
}

+ (void)launchForAPIKey:(NSString *)apiKey completion:(void(^)(void))completion failure:(void (^)(void))failureBlock {
    NSParameterAssert(apiKey);
    [self setUpForKey:apiKey isAsync:YES timeout:0 completion:completion failure:failureBlock];
}

+ (void)launchSynchronouslyForAPIKey:(NSString *) apiKey timeout:(NSTimeInterval)timeout {
    NSParameterAssert(apiKey);
    [self setUpForKey:apiKey isAsync:NO timeout:timeout completion:nil failure:nil];
}

+ (id)variationForKey:(NSString*)key {
    NSParameterAssert(key);
    return [VWOController.sharedInstance variationForKey:key];
}

+ (id)variationForKey:(NSString*)key defaultValue:(id)defaultValue {
    NSParameterAssert(key);
    NSParameterAssert(defaultValue);
    id object = [self variationForKey:key];
    if (!object) return defaultValue;
    return object;
}

+ (void)markConversionForGoal:(NSString*)goal {
    NSParameterAssert(goal);
    [VWOController.sharedInstance markConversionForGoal:goal withValue:nil];
}

+ (void)markConversionForGoal:(NSString*)goal withValue:(double)value {
    NSParameterAssert(goal);
    [VWOController.sharedInstance markConversionForGoal:goal withValue:[NSNumber numberWithDouble:value]];
}

+ (void)setCustomVariable:(NSString *)key withValue:(NSString *)value {
    NSParameterAssert(key);
    NSParameterAssert(value);
    [VWOController.sharedInstance setCustomVariable:key withValue:value];
}

+ (NSString*)version {
    return VWOSDK.version;
}
@end
